"""Bring Home Assistant and Music Assistant back to vovo's intended state.

Both keep part of their configuration in their own databases, outside Nix
(integration entries, the voice pipeline, player settings). A forced power-off
once reset Music Assistant to defaults. This runs after boot and every 30
minutes, checks each item and only changes what is wrong; normally it does
nothing. Needs the HA and MA tokens (agenix).
"""

import asyncio
import json
import os
import sys
import time
import urllib.error
import urllib.request

import websockets

HA = "http://127.0.0.1:8123"
MA = "http://127.0.0.1:8095"
PLAYER_ENTITY = "media_player.vovo"
MA_PLAYER_NAME = "vovo"
WYOMING_PORTS = [10300, 10200, 10400, 10700]  # whisper, piper, openwakeword, satellite
PIPELINE = {
    "name": "vovo",
    "language": "en",
    "conversation_engine": "conversation.home_assistant",
    "conversation_language": "en",
    "prefer_local_intents": True,
    "stt_engine": "stt.faster_whisper",
    "stt_language": "en",
    "tts_engine": "tts.piper",
    "tts_language": "en_US",
    "tts_voice": "en_US-amy-medium",
    "wake_word_entity": "wake_word.openwakeword",
    "wake_word_id": "hey_vovo",
}
MA_PLAYER_VALUES = {"volume_normalization_target": -12}


def log(*a):
    print(*a, flush=True)


def token(env):
    with open(os.environ[env]) as f:
        return f.read().strip()


def http(method, url, tok, payload=None):
    req = urllib.request.Request(url, method=method, data=json.dumps(payload).encode() if payload is not None else None,
                                 headers={"Authorization": "Bearer " + tok, "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        body = r.read()
    return json.loads(body) if body else None


def ha(method, path, payload=None):
    return http(method, HA + path, token("HA_TOKEN_FILE"), payload)


def ma(command, **args):
    return http("POST", MA + "/api", token("MA_TOKEN_FILE"), {"message_id": "1", "command": command, "args": args})


def wait_ready(timeout=900):
    end = time.time() + timeout
    while time.time() < end:
        try:
            ha("GET", "/api/")
            ma("config/providers")
            return True
        except Exception as e:
            log("waiting for HA/MA:", e)
            time.sleep(15)
    return False


class WS:
    async def __aenter__(self):
        self.ws = await websockets.connect(HA.replace("http", "ws") + "/api/websocket", max_size=None)
        await self.ws.recv()
        await self.ws.send(json.dumps({"type": "auth", "access_token": token("HA_TOKEN_FILE")}))
        assert json.loads(await self.ws.recv())["type"] == "auth_ok"
        self.n = 0
        return self

    async def __aexit__(self, *exc):
        await self.ws.close()

    async def call(self, msg):
        self.n += 1
        msg = dict(msg, id=self.n)
        await self.ws.send(json.dumps(msg))
        while True:
            m = json.loads(await self.ws.recv())
            if m.get("id") == self.n and m.get("type") == "result":
                if not m.get("success"):
                    raise RuntimeError("%s: %s" % (msg["type"], m.get("error")))
                return m.get("result")


def run_flow(handler, *steps):
    r = ha("POST", "/api/config/config_entries/flow", {"handler": handler, "show_advanced_options": False})
    for step in steps:
        if r.get("type") != "form":
            break
        r = ha("POST", "/api/config/config_entries/flow/" + r["flow_id"], step)
    return r.get("type"), r.get("reason") or r.get("title")


def ensure_entries():
    entries = ha("GET", "/api/config/config_entries/entry")
    # duplicate satellites added by zeroconf discovery compete with ours
    for e in entries:
        if e["domain"] == "wyoming" and e.get("source") == "zeroconf":
            log("removing duplicate wyoming entry", e["title"])
            ha("DELETE", "/api/config/config_entries/entry/" + e["entry_id"])
    have_wyoming = sum(1 for e in entries if e["domain"] == "wyoming" and e.get("source") != "zeroconf")
    if have_wyoming < len(WYOMING_PORTS):
        for port in WYOMING_PORTS:
            res = run_flow("wyoming", {"host": "127.0.0.1", "port": port})
            log("wyoming", port, res)  # already_configured is fine
    if not any(e["domain"] == "music_assistant" for e in entries):
        res = run_flow("music_assistant", {"url": MA}, {"token": token("MA_TOKEN_FILE")})
        log("music_assistant link", res)


async def ensure_ha_ws():
    async with WS() as ws:
        pipes = await ws.call({"type": "assist_pipeline/pipeline/list"})
        target = next((p for p in pipes["pipelines"] if p["name"] == "vovo"), None) \
            or next((p for p in pipes["pipelines"] if p["id"] == pipes["preferred_pipeline"]), None)
        if target is None:
            target = await ws.call(dict(PIPELINE, type="assist_pipeline/pipeline/create"))
            log("created pipeline")
        elif any(target.get(k) != v for k, v in PIPELINE.items()):
            await ws.call(dict(PIPELINE, type="assist_pipeline/pipeline/update", pipeline_id=target["id"]))
            log("pipeline settings restored")
        if pipes["preferred_pipeline"] != target["id"]:
            await ws.call({"type": "assist_pipeline/pipeline/set_preferred", "pipeline_id": target["id"]})
            log("pipeline set as preferred")
        exposed = (await ws.call({"type": "homeassistant/expose_entity/list"}))["exposed_entities"]
        if not exposed.get(PLAYER_ENTITY, {}).get("conversation"):
            await ws.call({"type": "homeassistant/expose_entity", "assistants": ["conversation"],
                           "entity_ids": [PLAYER_ENTITY], "should_expose": True})
            log("player exposed to Assist")


def ensure_ha_states():
    states = {s["entity_id"]: s for s in ha("GET", "/api/states")}
    sel = "select.vovo_finished_speaking_detection"
    if sel in states and states[sel]["state"] != "aggressive":
        ha("POST", "/api/services/select/select_option", {"entity_id": sel, "option": "aggressive"})
        log("speech end detection set to aggressive")


def ensure_ma_player():
    for p in ma("players/all"):
        if p.get("display_name") == MA_PLAYER_NAME:
            try:
                vals = ma("config/players/get", player_id=p["player_id"]).get("values", {})
            except Exception:
                vals = {}
            if any(vals.get(k, {}).get("value") != v for k, v in MA_PLAYER_VALUES.items()):
                ma("config/players/save", player_id=p["player_id"], values=MA_PLAYER_VALUES)
                log("MA player settings restored")
            return
    log("MA player", MA_PLAYER_NAME, "not registered (yet)")


HA_URL_FOR_MA = "http://vovo.local:8123"  # also where "log in with Home Assistant" sends the browser


def ensure_ma_hass():
    """Music Assistant's Home Assistant plugin: lets you log in to Music
    Assistant with your Home Assistant account. Music Assistant offers that
    login only while the plugin works, so a missing login provider means:
    add the plugin, or re-save it with the current token (fresh install)."""
    login = [p["provider_id"] for p in ma_noauth("auth/providers")]
    if "homeassistant" in login:
        return
    current = next((p for p in ma("config/providers") if p.get("domain") == "hass"), None)
    values = {"url": HA_URL_FOR_MA, "token": token("HA_TOKEN_FILE"), "verify_ssl": False}
    ma("config/providers/save", provider_domain="hass", values=values,
       instance_id=current["instance_id"] if current else None)
    log("MA Home Assistant plugin", "updated" if current else "added")


def ma_noauth(command, **args):
    req = urllib.request.Request(MA + "/api", method="POST",
                                 data=json.dumps({"message_id": "1", "command": command, "args": args}).encode(),
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read())


def main():
    if not wait_ready():
        sys.exit("HA/MA not reachable")
    for name, step in [("entries", ensure_entries), ("ha", lambda: asyncio.run(ensure_ha_ws())),
                       ("states", ensure_ha_states), ("ma player", ensure_ma_player),
                       ("ma hass", ensure_ma_hass)]:
        try:
            step()
        except Exception as e:  # keep going; the next run retries
            log("reconcile step failed:", name, e)
    log("reconcile done")


if __name__ == "__main__":
    main()
