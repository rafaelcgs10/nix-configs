{ pkgs, ...}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "$HOME/zsh_history/zsh_history";
      save = 1000000;
      size = 1000000;
      expireDuplicatesFirst = true;
      share = true;
      ignoreDups = true;
    };

    # oh-my-zsh removed: it was the main startup-time cost. The pieces we
    # actually used (completion, autosuggestions, syntax highlighting) are
    # loaded natively above; git info now lives in the Starship prompt.
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.1.0";
          sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
        };
      }
    ];

    sessionVariables = rec {
      NIXPKGS_ALLOW_UNFREE = 1;
      EDITOR = "vim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
      DIRENV_ALLOW_NIX = 1;
    };

    shellAliases = {
      # A few of the oh-my-zsh git aliases most people keep in muscle memory.
      # Trim or extend as you like.
      gst = "git status";
      gco = "git checkout";
      gc = "git commit -v";
      ga = "git add";
      gd = "git diff";
      gp = "git push";
      gl = "git pull";
      glog = "git log --oneline --graph --decorate";
    };
  };

  # Starship: fast (Rust), actively maintained, and free of p10k's
  # resize/redraw separator bug.
  #
  # Official "catppuccin-powerline" preset (mocha flavour), plus a NixOS os
  # symbol. Read straight from the TOML so the Nerd Font glyphs stay byte-exact.
  # The powerline separators only render correctly with a Nerd Font terminal
  # font (Hack Nerd Font Mono, set as the default monospace in
  # nixos/configuration.nix and in the alacritty/COSMIC terminal configs).
  #   https://starship.rs/presets/catppuccin-powerline
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./catppuccin-powerline.toml);
  };
}
