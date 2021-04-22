{ config, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> { };
  emacs-overlay = builtins.fetchTarball "https://github.com/nix-community/emacs-overlay/archive/15ed1f372a83ec748ac824bdc5b573039c18b82f.tar.gz";
  emacsPkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  mypolybar = unstable.polybar.override {
    alsaSupport = true;
    githubSupport = true;
    mpdSupport = true;
    pulseSupport = true;
  };
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "21.03";

  imports = [
    ./programs/xmonad/default.nix
  ];

  home.username = "rafael";
  home.homeDirectory = "/home/rafael";

  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "vim";
    DOOMDIR = "$HOME/nix-configs/doom.d";
    EMACSDIR = "$HOME/.emacs.d";
    DOOMLOCALDIR = "$HOME/.doom_local";
    DIRENV_ALLOW_NIX = 1;
  };

  home.file.".doom.d" = {
    source = builtins.toPath "/home/rafael/nix-configs/doom.d";
    onChange = "${pkgs.writeShellScript "doom-change" ''
      EMACSDIR=/home/rafael/.emacs.d
      DOOMBIN="$EMACSDIR"/bin/doom
      DOOMLOCALDIR=/home/rafael/.doom_local
      mkdir -p "$DOOMLOCALDIR"
      if [ ! -f "$DOOMBIN" ]; then
        echo "-------------> Installing DOOM EMACS"
        echo "$DOOMBIN"
        ls "$DOOMBIN"
        git clone --depth 1 https://github.com/hlissner/doom-emacs.git "$EMACSDIR"
        "$DOOMBIN" -y install
      else
        echo "-------------> Syncing DOOM EMACS"
        "$DOOMBIN" -y sync
      fi
    ''}";
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.ripgrep
    pkgs.jq
    pkgs.autorandr
    pkgs.tree
    pkgs.zsh
    pkgs.rnix-lsp
    pkgs.lazydocker
    pkgs.libgccjit
    pkgs.xorg.xwininfo
    pkgs.xmobar
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.lxrandr
    pkgs.texlive.combined.scheme-small

    pkgs.networkmanagerapplet

    pkgs.qbittorrent
    pkgs.spotify
    pkgs.pcmanfm
    pkgs.vivaldi
    pkgs.synergy
    pkgs.tdesktop
    pkgs.slack
    pkgs.flameshot
    pkgs.nitrogen
    pkgs.lxqt.qlipper

    emacsPkgs.emacsGcc
  ];

  programs.git = {
    enable = true;
    userName = "rafaelcgs10";
    userEmail = "rafaelcgs10@gmail.com";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;

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
        src = pkgs.lib.cleanSource ./programs/zsh/p10k;
        file = "p10k.zsh";
      }
    ];

    sessionVariables = rec {
      EDITOR = "vim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;
      DOOMLOCALDIR = "$HOME/.doom_local";
      DOOMDIR = "$HOME/nix-configs/doom.d";
      DIRENV_ALLOW_NIX = 1;
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = builtins.readFile ./programs/vim/extraConfig.vim;

    plugins = with pkgs.vimPlugins; [
      # Syntax / Language Support ##########################
      vim-nix
      vim-ruby # ruby
      vim-go # go
      # vim-fish # fish
      # vim-toml           # toml
      # vim-gvpr           # gvpr
      # rust-vim # rust
      zig-vim
      vim-pandoc # pandoc (1/2)
      vim-pandoc-syntax # pandoc (2/2)
      # yajs.vim           # JS syntax
      # es.next.syntax.vim # ES7 syntax

      # UI #################################################
      # gruvbox # colorscheme
      vim-gitgutter # status in gutter
      # vim-devicons
      vim-airline

      # Editor Features ####################################
      vim-surround # cs"'
      vim-repeat # cs"'...
      vim-commentary # gcap
      # vim-ripgrep
      vim-indent-object # >aI
      vim-easy-align # vipga
      vim-eunuch # :Rename foo.rb
      vim-sneak
      supertab
      # vim-endwise        # add end, } after opening block
      # gitv
      # tabnine-vim
      ale # linting
      nerdtree
      # vim-toggle-quickfix
      # neosnippet.vim
      neosnippet-snippets
      # splitjoin.vim
      nerdtree

      # Buffer / Pane / File Management ####################
      fzf-vim # all the things

      # Panes / Larger features ############################
      tagbar # <leader>5
      vim-fugitive # Gblame
    ];
  };

  programs.alacritty = {
    enable = true;

    settings = {
      scrolling.history = 10000;
      TERM = "xterm-256color";

      window = {
        padding = {
          x = 5;
          y = 5;
        };
      };

      draw_bold_text_with_bright_colors = true;
      font = {
        normal.family = "Mononoki Nerd Font";
        normal.style = "Regular";
        bold.family = "Mononoki Nerd Font";
        bold.style = "Regular";
        italic.family = "Mononoki Nerd Font";
        italic.style = "Regular";
        blod_italic.family = "Mononoki Nerd Font";
        blod_italic.style = "Regular";
        size = 12.0;
      };

      colors = {
        primary = {
          background = "0x282c34";
          foreground = "0xbbc2cf";
        };

        cursor = {
          background = "0x000000";
          foreground = "0xbbc2cf";
        };

        vi_mode_cursor = {
          background = "0x000000";
          foreground = "0xbbc2cf";
        };

        selection= {
          text = "0x000000";
          background = "0x44475a";
        };

        normal = {
          black   = "0x000000";
          red     = "0xff6c6b";
          green   = "0x98be65";
          yellow  = "0xecbe7b";
          blue    = "0x596889";
          magenta = "0xc678dd";
          cyan    = "0x46d9ff";
          white   = "0xdfdfdf";
        };

        bright = {
          black   = "0x3f444a";
          red     = "0xff6c6b";
          green   = "0x98be65";
          yellow  = "0xecbe7b";
          blue    = "0x51afef";
          magenta = "0xc678dd";
          cyan    = "0x46d9ff";
          white   = "0x9ca0a4";
        };
      };
    };
  };

  programs.autorandr.enable = true;

  # Interface stuff
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ./programs/rofi/theme.slate;
    cycle = true;
  };

  services.picom = {
    enable = true;
    blur = false;
    shadow = true;
    shadowOpacity = "0.65";
    extraOptions = ''
      mark-ovredir-focused = false;
      use-ewmh-active-win = true;
      round-borders = 1;
    '';
  };

  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
  };

  # Autoload nix shells
  # services.lorri.enable = true;

  services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./programs/polybar/config.ini;
    script = ''
      polybar mybar &
    '';
  };

  programs.direnv.enable = true;
  programs.direnv.enableNixDirenvIntegration = true;
}
