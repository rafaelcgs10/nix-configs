{ ... }:

# RapidRAW (installed for every host in home-manager/programs/graphical-apps/
# extras.nix): turn off its "Linux GPU optimization" on this AMD laptop.
#
# That setting, on by default, sets WEBKIT_DISABLE_DMABUF_RENDERER=1 and
# WEBKIT_DISABLE_COMPOSITING_MODE=1 (src-tauri/src/lib.rs, 1.5.8): an NVIDIA
# workaround that makes WebKit draw the whole interface on the CPU. Here the
# WebKitWebProcess sat at ~100% CPU and the interface glitched while a folder
# loaded; with it off, ~16% and smooth (2026-11-21). bbstation (NVIDIA) keeps
# the default.
#
# RapidRAW rewrites settings.json itself, so the file can't be a home.file;
# activation sets just this key. On a fresh install the file appears on the
# first RapidRAW start, and the next activation (switch/login) fixes it.
{
  home-manager.users.rafael =
    { pkgs, lib, ... }:
    {
      home.activation.rapidrawNoSoftwareRendering = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        f="$HOME/.local/share/io.github.CyberTimon.RapidRAW/settings.json"
        if [ -f "$f" ] && [ "$(${pkgs.jq}/bin/jq '.linuxGpuOptimization' "$f")" != false ]; then
          tmp=$(mktemp "$f.XXXXXX")
          if ${pkgs.jq}/bin/jq '.linuxGpuOptimization = false' "$f" > "$tmp"; then
            run mv "$tmp" "$f"
          else
            rm -f "$tmp"
          fi
        fi
      '';
    };
}
