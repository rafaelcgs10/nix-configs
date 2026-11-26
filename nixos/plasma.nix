{ ... }:

# KDE Plasma 6 desktop for thinkpad-e14 and bbstation. Plasma itself (and the
# apps built on its Qt) comes from nixpkgs-unstable through
# plasmaUnstableModule in flake.nix; desktop settings (theme, panel,
# shortcuts, default apps) are in home-manager/programs/kde.
{
  services.xserver.enable = true;
  # Plasma Login Manager, KDE's own login screen (replacing SDDM as Plasma's
  # default; nixpkgs-unstable's Plasma installer and graphical profile use it).
  # Its package comes from unstable's kdePackages through the overlay.
  services.displayManager = {
    defaultSession = "plasma";
    plasma-login-manager.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # One file picker everywhere: the plasma6 module sets up the KDE desktop
  # portal, and these make GTK apps use it too (GTK 3 and GTK 4 only do so on
  # request outside Flatpak), so their open/save dialogs are KDE's. Qt apps
  # get the KDE dialog from Plasma's platform theme; Electron/Chromium apps use
  # the portal on their own; LibreWolf is told to in its settings.
  environment.sessionVariables = {
    GTK_USE_PORTAL = "1";
    GDK_DEBUG = "portals";
  };
}
