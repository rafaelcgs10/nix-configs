"""Create vovo's Home Assistant / Music Assistant accounts and API tokens.

A freshly flashed card has an empty Home Assistant and Music Assistant: no
owner account, so no API token for vovo's scripts (reconcile, YouTube
fetcher, name correction, greeting). This runs at every boot and makes sure
both exist:

  Home Assistant  not onboarded: create the owner ("rafaelcgs") through the
                  onboarding API and finish onboarding; otherwise log in.
  Music Assistant no user: create the admin through /setup and mark
                  onboarding done; otherwise log in.

Then it mints a long-lived token for each and stores it in TOKEN_DIR (owned by
rafael), unless the token stored there still works. The password comes from
agenix (vovo-admin-password). vovo-reconcile then sets up everything else
(integrations, voice pipeline, Music Assistant providers and players).
"""

import asyncio
import json
import os
import pwd
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

import websockets

HA = "http://127.0.0.1:8123"
MA = "http://127.0.0.1:8095"
CLIENT_ID = "http://vovo.local:8123/"
USERNAME = "rafaelcgs"
DISPLAY_NAME = "Rafael"
TOKEN_DIR = "/var/lib/vovo"
TOKEN_OWNER = "rafael"
TOKEN_NAME = "vovo scripts"


def log(*a):
    print(*a, flush=True)


def request(method, url, payload=None, token=None, form=False):
    headers = {}
    data = None
    if payload is not None:
        if form:
            data = urllib.parse.urlencode(payload).encode()
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        else:
            data = json.dumps(payload).encode()
            headers["Content-Type"] = "application/json"
    if token:
        headers["Authorization"] = "Bearer " + token
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            body = r.read()
            return r.status, (json.loads(body) if body else None)
    except urllib.error.HTTPError as e:
        body = e.read()
        try:
            return e.code, json.loads(body)
        except ValueError:
            return e.code, None


def ma_api(command, token=None, **args):
    return request("POST", MA + "/api", {"message_id": "1", "command": command, "args": args}, token)


def wait_ready(timeout=900):
    end = time.time() + timeout
    while time.time() < end:
        try:
            ha_ok = request("GET", HA + "/auth/providers")[0] == 200
            ma_ok = ma_api("auth/providers")[0] == 200
            if ha_ok and ma_ok:
                return True
        except Exception as e:
            log("waiting:", e)
        time.sleep(10)
    return False


def read(path):
    try:
        with open(path) as f:
            return f.read().strip()
    except OSError:
        return ""


def store(name, token):
    os.makedirs(TOKEN_DIR, exist_ok=True)
    path = os.path.join(TOKEN_DIR, name)
    with open(path + ".tmp", "w") as f:
        f.write(token)
    u = pwd.getpwnam(TOKEN_OWNER)
    os.chown(path + ".tmp", u.pw_uid, u.pw_gid)
    os.chmod(path + ".tmp", 0o600)
    os.replace(path + ".tmp", path)
    log("stored", path)


# --- Home Assistant -------------------------------------------------------------

def ha_exchange(code):
    status, r = request("POST", HA + "/auth/token",
                        {"grant_type": "authorization_code", "code": code, "client_id": CLIENT_ID}, form=True)
    if status != 200:
        sys.exit("HA token exchange failed: %s %s" % (status, r))
    return r["access_token"]


def ha_access_token(password):
    # Once onboarded, HA no longer serves /api/onboarding (404).
    status, steps = request("GET", HA + "/api/onboarding")
    done = {s["step"]: s["done"] for s in (steps or [])} if status == 200 else {}
    if not done.get("user", True):
        status, r = request("POST", HA + "/api/onboarding/users", {
            "client_id": CLIENT_ID, "name": DISPLAY_NAME, "username": USERNAME,
            "password": password, "language": "en"})
        if status != 200:
            sys.exit("HA onboarding (user) failed: %s %s" % (status, r))
        access = ha_exchange(r["auth_code"])
        # The remaining steps take their values from configuration.yaml.
        for step, payload in (("core_config", {}), ("analytics", {}),
                              ("integration", {"client_id": CLIENT_ID, "redirect_uri": CLIENT_ID})):
            if not done.get(step, True):
                s, r = request("POST", HA + "/api/onboarding/" + step, payload, access)
                log("HA onboarding", step, s)
        log("HA owner created:", USERNAME)
        return access
    # Existing install: log in like the web UI does.
    status, flow = request("POST", HA + "/auth/login_flow", {
        "client_id": CLIENT_ID, "handler": ["homeassistant", None], "redirect_uri": CLIENT_ID})
    if status != 200:
        sys.exit("HA login flow failed: %s %s" % (status, flow))
    status, r = request("POST", HA + "/auth/login_flow/" + flow["flow_id"], {
        "username": USERNAME, "password": password, "client_id": CLIENT_ID})
    r = r or {}
    if r.get("type") != "create_entry":
        sys.exit("HA login failed (wrong password in vovo-admin-password?): %s" % r.get("errors"))
    return ha_exchange(r["result"])


async def ha_long_lived(access):
    async with websockets.connect(HA.replace("http", "ws") + "/api/websocket") as ws:
        await ws.recv()  # auth_required
        await ws.send(json.dumps({"type": "auth", "access_token": access}))
        if json.loads(await ws.recv()).get("type") != "auth_ok":
            sys.exit("HA websocket auth failed")
        await ws.send(json.dumps({"id": 1, "type": "auth/long_lived_access_token",
                                  "client_name": TOKEN_NAME, "lifespan": 3650}))
        r = json.loads(await ws.recv())
        if not r.get("success"):
            sys.exit("HA long-lived token failed: %s" % r)
        return r["result"]


def ensure_ha(password):
    path = os.path.join(TOKEN_DIR, "ha-token")
    tok = read(path)
    if tok and request("GET", HA + "/api/", token=tok)[0] == 200:
        log("HA token ok")
        return
    store("ha-token", asyncio.run(ha_long_lived(ha_access_token(password))))


# --- Music Assistant -------------------------------------------------------------

def ma_access_token(password):
    setup = {"username": USERNAME, "password": password, "device_name": "vovo-bootstrap"}
    status, r = request("POST", MA + "/setup", setup)
    if status == 200 and r and r.get("success"):
        access = r["token"]
        s, _ = ma_api("config/onboard_complete", access)
        log("MA admin created:", USERNAME, "onboarding", s)
        return access
    status, r = ma_api("auth/login", username=USERNAME, password=password, device_name="vovo-bootstrap")
    if not (r and r.get("success")):
        sys.exit("MA login failed (wrong password in vovo-admin-password?): %s" % (r or status))
    return r["access_token"]


def ensure_ma(password):
    path = os.path.join(TOKEN_DIR, "ma-token")
    tok = read(path)
    if tok:
        status, me = ma_api("auth/me", tok)
        if status == 200 and isinstance(me, dict) and me.get("username"):
            log("MA token ok")
            return
    access = ma_access_token(password)
    status, token = ma_api("auth/token/create", access, name=TOKEN_NAME)
    if status != 200 or not isinstance(token, str):
        sys.exit("MA long-lived token failed: %s %s" % (status, token))
    store("ma-token", token)


def main():
    password = read(os.environ["VOVO_ADMIN_PASSWORD_FILE"])
    if len(password) < 8:
        sys.exit("vovo-admin-password missing or shorter than 8 characters")
    if not wait_ready():
        sys.exit("Home Assistant / Music Assistant not reachable")
    ensure_ha(password)
    ensure_ma(password)


main()
