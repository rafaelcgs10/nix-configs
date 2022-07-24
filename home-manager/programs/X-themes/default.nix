{ pkgs, ...}:

{
  gtk = {
    enable = true;
    theme.package = pkgs.qogir-theme;
    # theme.name = "Adwaita-dark";
    theme.name = "Qogir-dark";
    iconTheme = {
      name = "Zafiro-icons";
      package = pkgs.zafiro-icons;
    };
  };

  home.pointerCursor = {
    x11 = {
      enable = true;
      defaultCursor = "left_ptr";
    };
    package = pkgs.qogir-icon-theme;
    name = "Qogir-dark";
    size = 28;
  };

  xresources.properties = { "Xft.dpi" = "96"; };
  xsession.profileExtra = ''
    export GDK_SCALE=1
    export GDK_DPI_SCALE=1
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
  '';
}
