{ pkgs, ...}:

{
  home.file.".doom.d" = {
    source = builtins.toPath "/home/rafael/nix-configs/doom.d";
    onChange = "${pkgs.writeShellScript "doom-change" ''
      EMACSDIR=/home/rafael/.emacs.d
      DOOMBIN="$EMACSDIR"/bin/doom
      DOOMLOCALDIR=/home/rafael/.doom_local
      mkdir -p "$DOOMLOCALDIR"
      if [ ! -f "$DOOMBIN" ]; then
        echo "-------------> Installing DOOM EMACS"
        mv "$EMACSDIR" "$EMACSDIR".bk
        git clone --depth 1 https://github.com/hlissner/doom-emacs.git "$EMACSDIR"
        "$DOOMBIN" -y install
      else
        echo "-------------> Syncing DOOM EMACS"
        "$DOOMBIN" -y sync
      fi
    ''}";
  };
}
