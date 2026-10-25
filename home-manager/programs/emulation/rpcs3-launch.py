"""RPCS3 launcher: pick player 1's input for CLI (--no-gui) boots.

The first connected game controller (as SDL sees it, any model) becomes
player 1 through RPCS3's SDL handler; with none connected the keyboard is
player 1. The profile is written to input_configs/global/auto.yml and made
the active global configuration (input_configs/active_input_configurations
.yml), which every boot path reads. RPCS3's --input-config option is not
used: it is honoured only when a game path is booted and silently ignored
on --last-savestate boots. Explicit --input-config, or GUI starts, are
left untouched.

Resume: when the launched game has savestates, RPCS3 is started with
--last-savestate <serial> instead of the game path, which boots the most
recent one (RPCS3 has no save-on-exit; states are made from its Home menu
or Ctrl+S). The serial comes from RPCS3's own games.yml (serial -> game
directory). RPCS3 aborts instead of booting when the newest state is not
compatible (made by another RPCS3 version); delete the state then.

Environment: RPCS3_BIN (the real binary), RPCS3_SDL (libSDL3.so to
enumerate with, the one RPCS3 ships), RPCS3_KEYBOARD_YML (keyboard profile
file to embed as player 1 when no pad is present).
"""
import ctypes
import os
import sys

argv = sys.argv[1:]
rpcs3 = os.environ["RPCS3_BIN"]
if "--no-gui" not in argv or any(a.startswith("--input-config") for a in argv):
    os.execv(rpcs3, [rpcs3] + argv)

CONFIG = os.path.join(
    os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config")),
    "rpcs3")


def resume_serial(paths):
    """Serial of the launched game if it has at least one savestate."""
    try:
        with open(os.path.join(CONFIG, "games.yml")) as f:
            games = [line.split(": ", 1) for line in f.read().splitlines()
                     if ": " in line]
    except OSError:
        return None
    for serial, game_dir in games:
        game_dir = game_dir.strip().rstrip("/")
        if not any(p == game_dir or p.startswith(game_dir + "/")
                   for p in paths):
            continue
        state_dir = os.path.join(CONFIG, "savestates", serial)
        if os.path.isdir(state_dir) and any(
                ".SAVESTAT" in n for n in os.listdir(state_dir)):
            return serial
    return None


game_paths = [os.path.abspath(a) for a in argv if not a.startswith("-")]
serial = resume_serial(game_paths)
if serial:
    argv = ([a for a in argv if a.startswith("-")]
            + ["--last-savestate", serial])


def pads():
    lib = ctypes.CDLL(os.environ["RPCS3_SDL"])
    lib.SDL_Init.restype = ctypes.c_bool
    lib.SDL_Init.argtypes = [ctypes.c_uint32]
    lib.SDL_GetGamepads.restype = ctypes.POINTER(ctypes.c_uint32)
    lib.SDL_GetGamepads.argtypes = [ctypes.POINTER(ctypes.c_int)]
    lib.SDL_GetGamepadNameForID.restype = ctypes.c_char_p
    lib.SDL_GetGamepadNameForID.argtypes = [ctypes.c_uint32]
    if not lib.SDL_Init(0x2000):  # SDL_INIT_GAMEPAD
        return []
    n = ctypes.c_int(0)
    ids = lib.SDL_GetGamepads(ctypes.byref(n))
    names = [lib.SDL_GetGamepadNameForID(ids[i]) for i in range(n.value)]
    lib.SDL_Quit()
    # RPCS3's SDL handler names the first device of a name "<name> 1".
    return [(raw or b"Unknown").decode() + " 1" for raw in names[:1]]


SDL_PAD = """  Handler: SDL
  Device: "{device}"
  Config:
    Left Stick Left: LS X-
    Left Stick Down: LS Y-
    Left Stick Right: LS X+
    Left Stick Up: LS Y+
    Right Stick Left: RS X-
    Right Stick Down: RS Y-
    Right Stick Right: RS X+
    Right Stick Up: RS Y+
    Start: Start
    Select: Back
    PS Button: Guide
    Square: West
    Cross: South
    Circle: East
    Triangle: North
    Left: Left
    Down: Down
    Right: Right
    Up: Up
    R1: RB
    R2: RT
    R3: RS
    L1: LB
    L2: LT
    L3: LS
    Large Vibration Motor Multiplier: 0
    Small Vibration Motor Multiplier: 0
  Buddy Device: "Null"
"""

devices = pads()
if devices:
    profile = "Player 1 Input:\n" + SDL_PAD.format(device=devices[0])
else:
    with open(os.environ["RPCS3_KEYBOARD_YML"]) as f:
        profile = f.read()

cfg_dir = os.path.join(CONFIG, "input_configs", "global")
os.makedirs(cfg_dir, exist_ok=True)
with open(os.path.join(cfg_dir, "auto.yml"), "w") as f:
    f.write(profile)
# Per-title entries would take precedence over "global"; this file only ever
# holds the launcher's choice (the GUI's pad dialog writes it too).
with open(os.path.join(CONFIG, "input_configs",
                       "active_input_configurations.yml"), "w") as f:
    f.write("Active Configurations:\n  global: auto\n")
os.execv(rpcs3, [rpcs3] + argv)
