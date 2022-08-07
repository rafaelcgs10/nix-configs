{ pkgs, ...}:

{
  programs.alacritty = {
    enable = true;

    settings = {
      scrolling.history = 100000;
      scrolling.auto_scroll = false;

      TERM = "xterm-256color";

      window = {
        padding = {
          x = 5;
          y = 5;
        };
      };

      draw_bold_text_with_bright_colors = true;
      font = {
        normal.family = "mononoki";
        normal.style = "Regular";
        bold.family = "mononoki";
        bold.style = "Regular";
        italic.family = "mononoki";
        italic.style = "Regular";
        blod_italic.family = "mononoki";
        blod_italic.style = "Regular";
        size = 10.0;
      };

      colors = {
        primary = {
          background = "0x282c34";
          foreground = "0xbbc2cf";
        };

        cursor = {
          background = "0xFFFFFF";
          foreground = "0x222222";
        };

        vi_mode_cursor = {
          background = "0xFFFFFF";
          foreground = "0xbbc2cf";
        };

        selection= {
          text = "0x000000";
          background = "0x44475a";
        };

        normal = {
          black   = "0x000000";
          red     = "0xfff403";
          green   = "0x98be65";
          yellow  = "0xecbe7b";
          blue    = "0x596889";
          magenta = "0xc678dd";
          cyan    = "0x46d9ff";
          white   = "0xdfdfdf";
        };

        bright = {
          black   = "0x3f444a";
          red     = "0xfff403";
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
}
