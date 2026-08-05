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
  # resize/redraw separator bug. Powerline look configured below.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;

      format = pkgs.lib.concatStrings [
        "[](color_orange)"
        "$os"
        "$username"
        "[](bg:color_yellow fg:color_orange)"
        "$directory"
        "[](fg:color_yellow bg:color_aqua)"
        "$git_branch"
        "$git_status"
        "[](fg:color_aqua bg:color_blue)"
        "$nix_shell"
        "$rust"
        "$golang"
        "$haskell"
        "$python"
        "[](fg:color_blue bg:color_bg3)"
        "$cmd_duration"
        "[](fg:color_bg3)"
        "$line_break"
        "$character"
      ];

      palette = "gruvbox_dark";

      palettes.gruvbox_dark = {
        color_fg0 = "#fbf1c7";
        color_bg1 = "#3c3836";
        color_bg3 = "#665c54";
        color_blue = "#458588";
        color_aqua = "#689d6a";
        color_green = "#98971a";
        color_orange = "#d65d0e";
        color_purple = "#b16286";
        color_red = "#cc241d";
        color_yellow = "#d79921";
      };

      os = {
        disabled = false;
        style = "bg:color_orange fg:color_fg0";
        symbols.NixOS = " ";
      };

      username = {
        show_always = true;
        style_user = "bg:color_orange fg:color_fg0";
        style_root = "bg:color_orange fg:color_fg0";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "fg:color_fg0 bg:color_yellow";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = "";
        style = "bg:color_aqua";
        format = "[[ $symbol $branch ](fg:color_fg0 bg:color_aqua)]($style)";
      };
      git_status = {
        style = "bg:color_aqua";
        format = "[[($all_status$ahead_behind )](fg:color_fg0 bg:color_aqua)]($style)";
      };

      nix_shell = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol $name ](fg:color_fg0 bg:color_blue)]($style)";
      };
      rust = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };
      golang = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };
      haskell = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version) ](fg:color_fg0 bg:color_blue)]($style)";
      };
      python = {
        symbol = "";
        style = "bg:color_blue";
        format = "[[ $symbol( $version)(($virtualenv)) ](fg:color_fg0 bg:color_blue)]($style)";
      };

      cmd_duration = {
        min_time = 500;
        style = "fg:color_fg0 bg:color_bg3";
        format = "[[  $duration ](fg:color_fg0 bg:color_bg3)]($style)";
      };

      line_break.disabled = false;

      character = {
        disabled = false;
        success_symbol = "[❯](bold fg:color_green)";
        error_symbol = "[❯](bold fg:color_red)";
        vimcmd_symbol = "[❮](bold fg:color_green)";
      };
    };
  };
}
