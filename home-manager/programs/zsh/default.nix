{ pkgs, lib, ...}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Interactive setup restored after dropping oh-my-zsh: async autosuggestions
    # (fixes backspace lag on the huge history), an arrow-selectable Tab menu,
    # and Ctrl+Arrow directory navigation. mkAfter so it runs after compinit and
    # the plugins are sourced.
    initContent = lib.mkAfter (builtins.readFile ./extra.zsh);
    autosuggestion = {
      enable = true;
      highlight = "fg=8"; # dim hint; ANSI slot so it follows the flavour
    };

    # zsh-syntax-highlighting colours expressed via ANSI palette slots (names,
    # not hex) so the command line renders in the terminal's *current*
    # Catppuccin flavour and follows the COSMIC day/night auto-switch (Latte by
    # day, Mocha by night) instead of being pinned to one flavour.
    syntaxHighlighting = {
      enable = true;
      styles = {
        "unknown-token" = "fg=red,bold";
        "reserved-word" = "fg=magenta";
        "alias" = "fg=green";
        "suffix-alias" = "fg=green";
        "global-alias" = "fg=green";
        "builtin" = "fg=green";
        "function" = "fg=green";
        "command" = "fg=green";
        "precommand" = "fg=green,underline";
        "hashed-command" = "fg=green";
        "arg0" = "fg=green";
        "single-hyphen-option" = "fg=yellow";
        "double-hyphen-option" = "fg=yellow";
        "single-quoted-argument" = "fg=yellow";
        "double-quoted-argument" = "fg=yellow";
        "dollar-quoted-argument" = "fg=yellow";
        "backtick-quoted-argument" = "fg=yellow";
        "globbing" = "fg=cyan";
        "history-expansion" = "fg=cyan";
        "command-substitution-delimiter" = "fg=cyan";
        "process-substitution-delimiter" = "fg=cyan";
        "path" = "fg=default,underline";
        "path_pathseparator" = "fg=default,underline";
        "comment" = "fg=8";
        "default" = "fg=default";
      };
    };

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
  # nixos/configuration.nix and in the COSMIC Terminal config).
  #   https://starship.rs/presets/catppuccin-powerline
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./catppuccin-powerline.toml);
  };
}
