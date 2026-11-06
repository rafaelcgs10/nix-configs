{ config, lib, pkgs, inputs, ... }:

# Local voice pipeline, all on the Pi (it must work with bbstation off):
#
#   Blue Yeti -> wyoming-satellite -> openWakeWord  ("ok nabu" / "hey vovo")
#                       |
#                       +-> Home Assistant Assist pipeline
#                             STT  Kroko streaming (sherpa) (tcp 10300)
#                             TTS  Piper amy-medium         (tcp 10200)
#                       <- spoken reply played through PipeWire
#
# All Wyoming services listen on localhost only; Home Assistant runs here too.
let
  wakeWordDir = "/var/lib/openwakeword/custom";

  # Chimes on wake word / end of command (not shipped in the nixpkgs package).
  satelliteSounds = rec {
    version = "1.4.1"; # keep in step with pkgs.wyoming-satellite
    awake = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/rhasspy/wyoming-satellite/v${version}/sounds/awake.wav";
      hash = "sha256-ayXdKrr3U3hlIiyp/W4U+/cjRYUm+3m74p2CYdEyByQ=";
    };
    done = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/rhasspy/wyoming-satellite/v${version}/sounds/done.wav";
      hash = "sha256-vFyRS/qGCnf6nYisLZZgGt/t5XjPFGY37Ji1aIkRqVE=";
    };
  };

  # Custom wake words trained on bbstation (see README). Copied into the
  # container's model dir; built-in ones (ok_nabu, hey_jarvis, ...) always work.
  # Every *.tflite in ./wakewords is loaded, and the satellite listens for
  # all of them ("hey vovo", "oki vovo", ...). The model name is the file name.
  customWakeWords = map (f: ./wakewords + "/${f}") (lib.filter (lib.hasSuffix ".tflite")
    (builtins.attrNames (builtins.readDir ./wakewords)));
  wakeWordNames =
    if customWakeWords != [ ] then map (m: lib.removeSuffix ".tflite" (baseNameOf (toString m))) customWakeWords
    else [ "okay_nabu" ]; # built into openWakeWord
in
{
  # --- speech to text -----------------------------------------------------------
  # Streaming zipformer (Kroko, via sherpa-onnx): it decodes while you speak,
  # so the text is ready ~0.5 s after you stop. Measured on this Pi
  # (2026-11-06, 12 spoken music commands, audio at real-time pace):
  #
  #   Whisper tiny.en int8 (3.1.0)       3.1 s after speech, 8.5 s CPU, 222 MB, 7/12 exact
  #   Kroko streaming, 4 threads         0.50 s,             4.3 s CPU, 262 MB, 10/12
  #   Kroko streaming, 2 threads         0.41 s,             2.5 s CPU, 258 MB, 10/12
  #   Kroko streaming, 1 thread (used)   0.57 s,             1.7 s CPU, 247 MB, 10/12
  #   zipformer-en-20M streaming         0.19 s,             1.5 s CPU, 184 MB, cut words
  #   Parakeet TDT (2026-11-05)          10-20 s, ~1.4 GB RAM+swap
  #
  # Whisper always pads to a 30 s window, so even "pause" cost ~8 s of CPU.
  # Kroko got "Daft Punk" and "Radiohead" where Whisper heard "Daphne Punk"
  # and "Flay Bohemian Rhapsody". It writes numbers as words ("forty
  # percent"); the volume automation converts them.
  # Streaming needs wyoming-faster-whisper >= 3.2 (stable 26.05 has 3.1.0).
  # The module adds the sherpa extras itself for sttLibrary = "sherpa".
  services.wyoming.faster-whisper.package =
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.wyoming-faster-whisper;
  services.wyoming.faster-whisper.servers.vovo = {
    enable = true;
    uri = "tcp://127.0.0.1:10300";
    language = "en";
    sttLibrary = "sherpa";
    model = "sherpa-onnx-streaming-zipformer-en-kroko-2025-08-06";
    device = "cpu";
    extraArgs = [ "--sherpa-streaming" "--cpu-threads" "1" ];
  };
  # Speech-to-text is the step the user waits for. Give it first call on the
  # CPU and keep it in RAM: with a YouTube download running, a 6 s clip went
  # from 13 s to under 4 s with Whisper (measured).
  systemd.services.wyoming-faster-whisper-vovo.serviceConfig = {
    CPUWeight = 1000;
    MemoryLow = "300M";
  };

  # --- text to speech -------------------------------------------------------------
  services.wyoming.piper.servers.vovo = {
    enable = true;
    uri = "tcp://127.0.0.1:10200";
    # Voice 6 of the samples: amy, played pitched up (see satellite below).
    voice = "en_US-amy-medium";
  };

  # --- wake word -------------------------------------------------------------------
  # nixpkgs' wyoming-openwakeword is marked broken on aarch64 (its bundled
  # tflite segfaults), so run the upstream image, the same build the Home
  # Assistant add-on uses on Raspberry Pis.
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.openwakeword = {
      image = "docker.io/rhasspy/wyoming-openwakeword:2.1.0";
      ports = [ "127.0.0.1:10400:10400" ];
      volumes = [ "${wakeWordDir}:/custom:ro" ];
      # 0.7: suggested by the training run (≈0.44 false activations/hour on
      # speech-heavy audio, ~72% recall on unseen synthetic voices).
      cmd = [ "--custom-model-dir" "/custom" "--threshold" "0.7" ];
      extraOptions = [ "--memory=200m" ];
    };
  };
  # Reload the models when one is added or changed.
  systemd.services.podman-openwakeword.restartTriggers = customWakeWords;
  systemd.tmpfiles.rules = [ "d ${wakeWordDir} 0755 root root -" ]
    # Copied, not symlinked: a link into /nix/store dangles inside the container.
    ++ map (m: "C+ ${wakeWordDir}/${baseNameOf (toString m)} 0644 root root - ${m}") customWakeWords;

  # --- satellite (microphone + speaker) ------------------------------------------
  # Runs as rafael so it reaches his PipeWire session; arecord/aplay go through
  # PipeWire's ALSA plugin, so the default source (the Yeti) and the current
  # output (jack or Bluetooth speaker) are used.
  services.wyoming.satellite = {
    enable = true;
    # Play the "done" chime as soon as the end of speech is detected, instead
    # of after speech-to-text has finished (which on the Pi takes seconds).
    package = pkgs.wyoming-satellite.overridePythonAttrs (old: {
      doCheck = false;
      postPatch = (old.postPatch or "") + ''
        ${pkgs.python3.interpreter} - <<'EOF'
        p = "wyoming_satellite/satellite.py"
        s = open(p).read()
        a = "        await run_event_command(self.settings.event.transcript, transcript.text)\n        await self._play_wav(self.settings.snd.done_wav)\n"
        assert a in s, "satellite.py changed upstream: update this patch"
        s = s.replace(a, "        await run_event_command(self.settings.event.transcript, transcript.text)\n")
        i = s.index("    async def trigger_stt_stop(self) -> None:")
        j = s.index("\n\n", i)
        s = s[:j] + "\n        await self._play_wav(self.settings.snd.done_wav)" + s[j:]
        open(p, "w").write(s)
        EOF
      '';
    });
    user = "rafael";
    name = "vovo";
    uri = "tcp://0.0.0.0:10700"; # Home Assistant connects locally; port stays firewalled
    microphone = {
      command = "arecord -D pipewire -r 16000 -c 1 -f S16_LE -t raw";
      autoGain = 5;
      noiseSuppression = 2;
    };
    # Cute voice: everything vovo says (and its chimes) is pitched up 7
    # semitones and sped up 10% on the way to the speaker. Raw 22.05 kHz
    # mono 16-bit in (the satellite's sound format), same out.
    sound.command = toString (pkgs.writeShellScript "vovo-speaker" ''
      ${pkgs.sox}/bin/sox -q -t raw -r 22050 -e signed -b 16 -c 1 - \
        -t raw -r 22050 -e signed -b 16 -c 1 - pitch 700 tempo 1.1 \
        | ${pkgs.alsa-utils}/bin/aplay -q -D pipewire -r 22050 -c 1 -f S16_LE -t raw
    '');
    sounds = {
      awake = "${satelliteSounds.awake}";
      done = "${satelliteSounds.done}";
    };
    extraArgs = [
      "--wake-uri" "tcp://127.0.0.1:10400"
      # Home Assistant is configured with the satellite explicitly; zeroconf
      # discovery added a second, competing entry for the same satellite.
      "--no-zeroconf"
    ] ++ lib.concatMap (n: [ "--wake-word-name" n ]) wakeWordNames;
  };
  # The satellite needs rafael's PipeWire and the wake word service to be up.
  systemd.services.wyoming-satellite = {
    after = [ "user@1000.service" "podman-openwakeword.service" ];
    wants = [ "user@1000.service" "podman-openwakeword.service" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
      CPUWeight = 500;
      # Microphone capture (arecord) and vovo's voice (sox | aplay) are
      # PipeWire clients; with these limits their audio threads run
      # real-time, like PipeWire itself (audio.nix), so a busy CPU does not
      # drop or delay microphone samples or chop the spoken replies. The
      # satellite itself gets ahead of background work and is never swapped.
      # The module's hardening sets RestrictRealtime=yes, which makes
      # PipeWire's real-time request fail (and fall back to rtkit, which
      # refuses a headless session); the rest of the hardening stays.
      RestrictRealtime = lib.mkForce false;
      LimitRTPRIO = 95;
      LimitNICE = -19;
      Nice = -5;
      MemorySwapMax = 0;
    };
  };
}
