# agenix: age-encrypted secrets, decrypted at activation into /run/agenix.
#
# Imported per-host from flake.nix. A host can only be given this module once
# its SSH host key is a recipient in secrets/secrets.nix (otherwise activation
# fails when it cannot decrypt) — so add the key, `agenix --rekey`, and only
# then import this here.
#
# Decryption uses config.services.openssh.hostKeys by default, which all our
# hosts have, so nothing extra has to be distributed to a machine.
{ inputs, ... }:

{
  imports = [ inputs.agenix.nixosModules.default ];

  # CIFS credentials for the //192.168.0.104 shares. Root-only (0400 by
  # default), which is what mount.cifs needs. The NAS mounts are
  # x-systemd.automount, so they are triggered on first access — long after
  # activation has populated /run/agenix — and never race with decryption.
  age.secrets.smb-secrets.file = ../secrets/smb-secrets.age;
}
