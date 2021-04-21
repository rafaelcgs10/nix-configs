{ config, pkgs, ... }:

let
  # nix-doom-emacs = import ./doom-emacs.nix;
  emacs-overlay = builtins.fetchTarball "https://github.com/nix-community/emacs-overlay/archive/15ed1f372a83ec748ac824bdc5b573039c18b82f.tar.gz";
  emacsPkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  pkgs2003 = import
  (builtins.fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-20.03.tar.gz)
    # reuse the current configuration
    { inherit config; };
  inherit (pkgs) haskellPackages;
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "21.03";

  imports = [
    # ./programs/i3.nix
    ./programs/xmonad/default.nix
    # ./doom-emacs-custom.nix
  ];

  home.username = "rafael";
  home.homeDirectory = "/home/rafael";

  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "vim";
    DOOMDIR = "$HOME/nix-configs/.doom.d";
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
    pkgs.nix
    pkgs.lazydocker
    pkgs.libgccjit
    pkgs.xorg.xwininfo
    pkgs.xmobar
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.texlive.combined.scheme-small

    pkgs.networkmanagerapplet

    pkgs.qbittorrent
    pkgs.spotify
    pkgs.pcmanfm
    pkgs.vivaldi
    pkgs.synergy
    pkgs.tdesktop
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
      # DOOMDIR = "$HOME/.doom.d";
      DOOMDIR = "$HOME/nix-configs/doom.d";
      DIRENV_ALLOW_NIX = 1;
      # DOOMDIR = "/home/rafael/Documents/nix-configs/doom.d";
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
      gruvbox # colorscheme
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

  programs.kitty = {
    enable = true;

    settings = {
      font = "mononoki";
      scrollback_lines = 10000;
      tab_bar_edge = "bottom";
      enable_audio_bell = false;
      extraConfig = builtins.readFile ./programs/kitty/theme.conf;
    };
  };

  programs.autorandr.enable = true;

  # Interface stuff
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = ./programs/rofi/theme.slate;
    cycle = true;
  };

  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
  };

  # Autoload nix shells
  # services.lorri.enable = true;

  programs.direnv.enable = true;
  programs.direnv.enableNixDirenvIntegration = true;
}
