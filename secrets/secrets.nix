# agenix recipients ("rules"): which keys may decrypt which secret.
#
# This file is only read by the `agenix` CLI, never by NixOS itself. After
# changing it, run `agenix --rekey` from a machine that can already decrypt
# (any machine holding one of the listed private keys) and commit the result.
#
# Adding a machine:
#   1. get its host key:  cat /etc/ssh/ssh_host_ed25519_key.pub   (or ssh-keyscan HOST)
#   2. add it below and to the relevant secrets' publicKeys list
#   3. agenix --rekey && git commit
#
# `rafael` (the user key) is a recipient of everything on purpose: it is the
# recovery path. Without a user key, losing every machine would make these
# files permanently undecryptable.
let
  # --- user keys -------------------------------------------------------------
  rafael = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWSQ3x9iRPZ3cj11zCwSSWz/vFPakybnrP+324/RuPK rafaelcgs10@gmail.com";

  # --- host keys (from /etc/ssh/ssh_host_ed25519_key.pub) ---------------------
  thinkpad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFP8Rwy2r09UXCRmmLOvbZxkJ0VlQSMS93LY0nXr9LRM root@thinkpad";
  # vovo's key was pre-generated on bbstation and copied onto the SD card at
  # flash time (nixos/vovo/prepare-sd.sh), so its secrets work on first boot.
  vovo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQfaYe5GT5lzY5bfmLsZICJiZzrmNiGxZTDAAi0REl9 root@vovo";
  bbstation = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWD13u07BkEULTHWqOYvEIifsuRJvyXEeK11tm/wUmd root@nixos";
  # TODO: add when the machine is reachable (`ssh-keyscan -t ed25519 <host>`),
  # then `agenix --rekey` and switch its CIFS mounts over as well.
  # bbtablet  = "ssh-ed25519 ...";

  allUsers = [ rafael ];
  allHosts = [ thinkpad ];
in
{
  # CIFS credentials for the //192.168.0.104 shares (username=/password= file).
  "smb-secrets.age".publicKeys = allUsers ++ allHosts;

  # vovo (Raspberry Pi music box). bbstation is a recipient only so these can
  # be edited there: sudo agenix -e X.age -i /etc/ssh/ssh_host_ed25519_key
  "wifi-vovo.age".publicKeys = allUsers ++ [ vovo bbstation ];        # psk_home=<wpa passphrase>
  "syncthing-vovo-key.age".publicKeys = allUsers ++ [ vovo bbstation ]; # Syncthing identity (key.pem)
  "syncthing-vovo-gui.age".publicKeys = allUsers ++ [ vovo bbstation ]; # Syncthing web UI password
  "rafael-password-vovo.age".publicKeys = allUsers ++ [ vovo bbstation ]; # yescrypt hash; console login
}
