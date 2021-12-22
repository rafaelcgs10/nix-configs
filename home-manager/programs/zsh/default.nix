{ pkgs, ...}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    history = {
      path = "$HOME/zsh_history/zsh_history";
      save = 1000000;
      size = 1000000;
      expireDuplicatesFirst = true;
      share = true;
      ignoreDups = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "git-auto-fetch" "git-extras" "dirhistory" ];
    };

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
      {
        name = "zsh-git";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-git";
          rev = "v0.6.3";
          sha256 = "1h8h2mz9wpjpymgl2p7pc146c1jgb3dggpvzwm9ln3in336wl95c";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.6.3";
          sha256 = "1h8h2mz9wpjpymgl2p7pc146c1jgb3dggpvzwm9ln3in336wl95c";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "be3882aeb054d01f6667facc31522e82f00b5e94";
          sha256 = "0w8x5ilpwx90s2s2y56vbzq92ircmrf0l5x8hz4g1nx3qzawv6af";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = pkgs.lib.cleanSource ./p10k;
        file = "p10k.zsh";
      }
    ];
    sessionVariables = rec {
      NIXPKGS_ALLOW_UNFREE = 1;
      EDITOR = "vim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
      DOOMLOCALDIR = "$HOME/.doom_local";
      DOOMDIR = "$HOME/nix-configs/doom.d";
      DIRENV_ALLOW_NIX = 1;
    };
    shellAliases = rec {
    };
  };
}
