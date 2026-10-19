# COSMIC panel applet that lists local Docker/Podman containers and can start,
# stop, restart or remove them (cosmic-utils). Not in nixpkgs yet; this follows
# nixpkgs' pkgs/by-name/co/cosmic-ext-applet-caffeine/package.nix so it can be
# upstreamed as-is. The justfile's `install` target also drops the generated
# .desktop/.metainfo (build.rs + xdgen) and the symbolic icon the panel uses.
#
# Runtime lookup of `docker`/`podman` follows the applet's PATH (the panel's
# session env includes /run/current-system/sw/bin, where docker lives).
#
# Update: bump rev/hash, set cargoHash = lib.fakeHash, rebuild, copy the hash.
{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
}:
rustPlatform.buildRustPackage {
  pname = "cosmic-ext-applet-container-manager";
  version = "0.1.1-unstable-2026-10-18";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "cosmic-ext-applet-container-manager";
    rev = "72d5be5b6804b4a5a374da2f52b30daaa70763ab";
    hash = "sha256-ElS7NBTLN1DEPHwKTIyrIZS2X/i/l1XU7cD1b5IptCg=";
  };

  cargoHash = "sha256-jw2Z0/no9OX55tN9vvB+EfG+MiyugBVKvSyVDxhRBbI=";

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  # This test spawns a detached grandchild and asserts it cannot keep the
  # action's output pipes open; inside the Nix sandbox the process/pipe
  # semantics it relies on differ and it fails. Pure test-harness concern.
  checkFlags = [
    "--skip"
    "detached_descendant_cannot_hold_action_output_pipes_open"
  ];

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    # buildRustPackage builds into target/<triple>/release; the justfile
    # expects target-dir/release/<name>.
    "--set"
    "target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  meta = {
    description = "Container Manager applet for the COSMIC desktop (Docker/Podman)";
    homepage = "https://github.com/cosmic-utils/cosmic-ext-applet-container-manager";
    license = lib.licenses.gpl3Only;
    mainProgram = "cosmic-ext-applet-container-manager";
    platforms = lib.platforms.linux;
  };
}
