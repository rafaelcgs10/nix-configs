# Graphical boot splash (Plymouth), shared by bbstation, bbtablet and
# thinkpad-e14. Imported per-host from flake.nix like io-performance.nix.
#
# Plymouth itself is bootloader-agnostic: it is driven by the kernel/initrd, so
# the same config works on bbstation (GRUB) and on the two systemd-boot hosts.
#
# Deliberate divergence from https://wiki.nixos.org/wiki/Plymouth: the wiki
# recipe optimises for a *fully silent* boot. We want a clean splash but must
# still see failures, so the two settings that would hide them are changed —
# see consoleLogLevel and loader.timeout below.
#
# No LUKS is used on any of these hosts (thinkpad-e14's eCryptfs home is
# unlocked by PAM at login, long after Plymouth exits), so the wiki's warning
# that only the `bgrt` theme guarantees a graphical disk-password prompt does
# not apply here — we are free to use a custom theme.
{ pkgs, ... }:

{
  boot.plymouth = {
    enable = true;

    # "colorful_sliced" = preview 15 of adi1090x/plymouth-themes: a rainbow
    # sliced sphere on black. Overriding selected_themes builds only this one
    # theme (~5MB) instead of the whole collection (~524MB).
    theme = "colorful_sliced";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [ "colorful_sliced" ];
      })
    ];
  };

  # Quiet enough for the splash to be the only thing on screen, but not so
  # quiet that a real failure scrolls past invisibly.
  boot.kernelParams = [
    "quiet"
    "rd.udev.log_level=3"
    # systemd keeps its status output hidden *unless* a unit fails.
    "rd.systemd.show_status=auto"
  ];

  # Kernel prints messages with level < consoleLogLevel. The wiki suggests 3,
  # which prints only emerg/alert/crit and therefore *hides* plain `err`
  # messages — exactly the ones worth seeing. 4 keeps `err` visible.
  boot.consoleLogLevel = 4;

  # Hide the initrd's own chatter; failures there still surface via the
  # escape hatches below.
  boot.initrd.verbose = false;

  # NOTE: boot.loader.timeout is intentionally NOT set to 0 here (the wiki
  # suggests it). Keeping the menu reachable is what lets you boot a previous
  # generation after a bad rebuild, and bbstation/thinkpad-e14 both list
  # Windows entries that would otherwise become unreachable.
  #
  # If a boot goes wrong:
  #   * press ESC during the splash to drop to the full text log;
  #   * in the boot menu press `e` to edit the entry and delete `quiet` (and
  #     add `plymouth.enable=0`) for a one-off verbose boot;
  #   * pick an older generation from the menu;
  #   * after the fact: `journalctl -b -1 -p err`.
}
