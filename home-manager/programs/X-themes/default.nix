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

  xsession.pointerCursor = {
    package = pkgs.qogir-icon-theme;
    name = "Qogir-dark";
    size = 28;
  };
}
