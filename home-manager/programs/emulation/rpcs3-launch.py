"""RPCS3 launcher: pick player 1's input for CLI (--no-gui) boots.

The first connected game controller (as SDL sees it, any model) becomes
player 1 through RPCS3's SDL handler; with none connected the keyboard is
player 1. The profile is written to input_configs/global/auto.yml and passed
with --input-config, which RPCS3 only honours together with --no-gui (ES-DE
launches). Explicit --input-config, or GUI starts, are left untouched.

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

cfg_dir = os.path.join(
    os.environ.get("XDG_CONFIG_HOME", os.path.expanduser("~/.config")),
    "rpcs3", "input_configs", "global")
os.makedirs(cfg_dir, exist_ok=True)
with open(os.path.join(cfg_dir, "auto.yml"), "w") as f:
    f.write(profile)
os.execv(rpcs3, [rpcs3, "--input-config", "auto"] + argv)
