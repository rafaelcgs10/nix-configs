{ config, pkgs, lib, ... }:

# Daily flake.lock update for ~/nix-configs, run as rafael. This is the
# writing half of the auto-upgrade split: if root's nixos-upgrade.service
# (nixos/configuration.nix, 12:00) updated the lock itself, every run would
# leave root-owned files in the checkout (flake.lock, .git/index, refs,
# objects) and rafael's own git would start failing with permission errors.
# So this user timer updates/commits/pushes at ~11:00, and the root service
# only rebuilds what is committed (--no-write-lock-file).
#
# Runs inside the login session, so on the machines with an ecryptfs home the
# repo is guaranteed to be mounted. Not logged in => no update that day, and
# the noon rebuild just rebuilds the current lock.
#
# Two lanes: the daily timer (Sun-Fri) only moves the cheap, well-cached
# inputs listed in dailyInputs below; the Saturday timer runs a full
# `nix flake update`, letting the compile-heavy inputs (doom-emacs stack,
# affinity-nix, spektrafilm darktable) move once a week instead of daily.
#
# nix-configs-revert is the failure path: when nixos-upgrade fails WITHOUT
# having switched generations (i.e. the new lock does not even build), its
# failure hook starts this service, which reverts the auto-update commit and
# pushes, so no other machine installs the known-bad lock. The update script
# then refuses to re-propose a lock identical to the last reverted one, or
# the pair would flip-flop daily until upstream moves.

let
  repo = "${config.home.homeDirectory}/nix-configs";

  # Inputs the daily run is allowed to move. Everything NOT listed here sits
  # on the weekly lane (Saturday full update) because a bump forces hours of
  # local compilation: nix-doom-emacs-unstraightened (+ its emacs-overlay/
  # doomemacs graph, ~120 uncached emacs packages), affinity-nix (multi-GB
  # wine prefix rebuild) and spektrafilm-art-darktable (full darktable
  # compile). Measured over 30 days those three moved 22/9/5 times and
  # caused nearly all local build time, while the inputs below are either
  # Hydra/cachix-cached or trivial to build.
  # nixpkgs-darktable/-isabelle/-lmstudio are pinned to fixed revs in
  # flake.nix, so listing them would be a no-op; they are left out.
  dailyInputs = [
    "nixpkgs"
    "nixpkgs-unstable"
    "nixpkgs2511"
    "home-manager"
    "stylix"
    "firefox-addons"
    "nixos-hardware"
    "agenix"
    "cos-cli"
    "cosmic-manager"
    "plasma-manager"
    "winapps"
  ];

  updateScript = pkgs.writeShellScript "nix-configs-update" ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.git pkgs.nix pkgs.openssh pkgs.coreutils pkgs.gnugrep pkgs.libnotify pkgs.util-linux ]}
    cd ${repo}

    # The daily and weekly units share this script and the repo; if their
    # timers ever fire together (Persistent catch-up after a long poweroff),
    # let one finish before the other starts.
    exec 9>.git/nix-configs-update.lock
    flock 9

    # systemd user units normally carry DBUS_SESSION_BUS_ADDRESS; fall back to
    # the standard per-uid bus path so the COSMIC popup always works.
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
    notify() { notify-send -a "Nix configs" "$@" || true; }

    # Never touch a repo that is mid-merge/rebase.
    if [ -e .git/MERGE_HEAD ] || [ -e .git/rebase-merge ] || [ -e .git/rebase-apply ]; then
      echo "merge/rebase in progress; skipping" >&2
      exit 1
    fi

    # Uncommitted flake.lock changes are WIP; don't clobber them.
    if ! git diff --quiet -- flake.lock || ! git diff --cached --quiet -- flake.lock; then
      echo "flake.lock has local modifications; skipping" >&2
      exit 1
    fi

    # Best-effort catch-up with origin. --ff-only never touches uncommitted
    # WIP and can never conflict; if history has diverged, continue from the
    # local state and let the usual manual pull/merge reconcile it later.
    git pull --ff-only || echo "cannot fast-forward; updating from local state" >&2

    # Capture the update output (journal keeps it via tee) to list which
    # inputs moved in the notification. Package-level version bumps are not
    # knowable here — that summary comes from the nixos-upgrade finish
    # notification (nvd diff of the two system generations).
    update_log=$(mktemp)
    trap 'rm -f "$update_log"' EXIT
    # With input names as arguments only those inputs move (daily lane);
    # with no arguments everything moves (weekly full run).
    nix flake update --extra-experimental-features 'nix-command flakes' "$@" 2>&1 | tee "$update_log"

    if git diff --quiet -- flake.lock; then
      echo "flake.lock already up to date"
      exit 0
    fi

    # Anti-flip-flop: if the fresh lock is byte-identical to the one the last
    # auto-revert rolled back, upstream has not moved past the known-bad
    # state — restore the committed lock and wait for a real change.
    bad_commit=$(git log -n 1 --grep='^This reverts commit' --grep='flake\.lock: auto-update' \
      --all-match --format=%b | grep -oP '(?<=This reverts commit )[0-9a-f]+' | head -n 1 || true)
    if [ -n "$bad_commit" ] \
        && [ "$(git hash-object flake.lock)" = "$(git rev-parse --verify -q "$bad_commit:flake.lock" || echo none)" ]; then
      git checkout -- flake.lock
      echo "update is identical to reverted commit $bad_commit; skipping" >&2
      notify "Nix configs: known-bad update skipped" \
        "Today's flake.lock equals the previously reverted one ($bad_commit); staying on the last good lock."
      exit 0
    fi

    inputs=$(grep -oP "(?<=Updated input ')[^']+" "$update_log" | sort -u | tr '\n' ' ')

    # Commit only flake.lock, whatever else is dirty or staged.
    git commit --no-verify -m "flake.lock: auto-update ($(uname -n))" -- flake.lock

    # A failed push (offline, key locked, or another machine pushed first) is
    # not fatal: the commit exists locally and the next push carries it.
    if git push; then
      push_note="pushed to origin"
    else
      echo "push failed; will retry on the next run" >&2
      push_note="push failed — will retry on the next run"
    fi

    notify "Nix configs: update proposed" \
      "Inputs updated: ''${inputs:-see journal}($push_note; installs at the next nixos-upgrade run)"
  '';

  revertScript = pkgs.writeShellScript "nix-configs-revert" ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.coreutils pkgs.gnugrep pkgs.libnotify ]}
    cd ${repo}

    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}"
    notify() { notify-send -a "Nix configs" "$@" || true; }

    # Only revert the exact thing the updater auto-committed: HEAD must be an
    # auto-update lock commit and the lock otherwise untouched. Anything else
    # (user commits on top, WIP lock edits) is a human's call, not ours.
    if ! git log -1 --format=%s | grep -q '^flake\.lock: auto-update'; then
      echo "HEAD is not an auto-update commit; nothing to revert" >&2
      exit 0
    fi
    if ! git diff --quiet -- flake.lock || ! git diff --cached --quiet -- flake.lock; then
      echo "flake.lock has local modifications; not reverting" >&2
      exit 1
    fi

    bad=$(git rev-parse HEAD)
    subject=$(git log -1 --format=%s)

    # Hand-rolled single-file revert instead of `git revert`: revert/cherry-pick
    # refuse to run with anything staged, and WIP in this repo is normal. The
    # message mimics git's format because the updater's anti-flip-flop guard
    # parses "This reverts commit <sha>".
    git checkout "$bad~1" -- flake.lock
    git commit --no-verify -m "Revert \"$subject\"" -m "This reverts commit $bad." -- flake.lock

    if git push; then
      push_note="pushed to origin"
    else
      echo "push failed; will retry on the next update run" >&2
      push_note="push failed — other machines may still install it"
    fi

    notify -u critical "Nix configs: bad update reverted" \
      "flake.lock rolled back to the last good state ($push_note). The updater will skip this exact lock until upstream moves."
  '';
in
{
  systemd.user.services.nix-configs-update = {
    Unit.Description = "Update, commit and push flake.lock in ~/nix-configs (cheap inputs only)";
    Service = {
      Type = "oneshot";
      ExecStart = "${updateScript} ${lib.escapeShellArgs dailyInputs}";
    };
  };

  systemd.user.services.nix-configs-update-full = {
    Unit.Description = "Weekly full flake.lock update in ~/nix-configs (all inputs)";
    Service = {
      Type = "oneshot";
      ExecStart = "${updateScript}";
    };
  };

  systemd.user.services.nix-configs-revert = {
    Unit.Description = "Revert a flake.lock auto-update that failed to build";
    Service = {
      Type = "oneshot";
      ExecStart = "${revertScript}";
    };
  };

  systemd.user.timers.nix-configs-update = {
    Unit.Description = "Daily flake.lock auto-update (before the 12:00 nixos-upgrade)";
    Timer = {
      # Saturday belongs to the full run below; skipping it here avoids two
      # updates racing for the same 11:00 slot.
      OnCalendar = "Mon..Fri,Sun 11:00";
      RandomizedDelaySec = "20min";
      # Catch up on the next login if 11:00 was missed (machine off / logged out).
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.timers.nix-configs-update-full = {
    Unit.Description = "Weekly full flake.lock auto-update, expensive inputs included";
    Timer = {
      OnCalendar = "Sat 11:00";
      RandomizedDelaySec = "20min";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
