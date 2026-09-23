# withoutbg-inference: the FastAPI/ONNX server the withoutbg GIMP plug-in
# talks to. https://github.com/withoutbg/withoutbg-inference (Apache-2.0)
#
# Upstream only ships this as Docker images, but the app itself is plain
# Python -- nothing in it is container-specific except the default model path,
# which is an env var we override anyway. So it is built straight from the
# repo; the ui/ (Next.js dashboard) and docker/ trees are simply not installed.
#
# The GIMP plug-in hard-codes http://127.0.0.1:8000, and we do not want a
# ~600MB-resident daemon sitting there for the 99% of the time nobody is
# cutting out a subject. extras.nix therefore runs this under systemd *socket*
# activation: systemd owns the listening socket, and the first connection from
# the plug-in is what starts the process. `withoutbg-inference-server` below is
# the other half of that -- it serves on the inherited fd and exits again once
# it has been idle, so the steady state really is zero processes.
{
  lib,
  python3Packages,
  fetchFromGitHub,
  writeText,
  callPackage,
  withoutbg-open-weights ? callPackage ./withoutbg-open-weights.nix { },
  # Seconds without a request before the server shuts itself down. A restart
  # costs ~4s (ONNX load + the sha256 verification config.py demands + a warm-up
  # inference), so this trades that against holding ~600MB RSS; five minutes
  # comfortably covers working through a batch of images.
  idleTimeout ? 300,
}:

let
  # Kept out of postInstall as its own file rather than a heredoc: it is real
  # Python, and burying it in shell quoting helps nobody.
  serverScript = writeText "withoutbg-inference-server" ''
    #!${python3Packages.python.interpreter}
    """Serve withoutbg_api on a systemd-activated socket, exiting when idle.

    uvicorn has no notion of "stop when nobody is using me", and systemd's own
    StopWhenUnneeded= cannot see HTTP traffic, so the idle check has to live
    here. The ASGI wrapper is deliberately raw rather than a Starlette
    middleware: it also sees the long-lived `lifespan` scope, which is what
    starts the idle clock for a server nobody ever actually talks to.
    """

    import os
    import signal
    import threading
    import time

    import uvicorn
    from withoutbg_api.main import app

    IDLE_TIMEOUT = float(
        os.environ.get("WITHOUTBG_IDLE_TIMEOUT", "${toString idleTimeout}")
    )

    _last_activity = time.monotonic()


    class _TouchOnRequest:
        def __init__(self, inner):
            self._inner = inner

        async def __call__(self, scope, receive, send):
            global _last_activity
            _last_activity = time.monotonic()
            try:
                await self._inner(scope, receive, send)
            finally:
                _last_activity = time.monotonic()


    def _idle_watchdog():
        while time.monotonic() - _last_activity < IDLE_TIMEOUT:
            time.sleep(5.0)
        # SIGTERM rather than sys.exit: it reaches uvicorn's own signal handler,
        # so a request that landed in the last instant still gets drained.
        os.kill(os.getpid(), signal.SIGTERM)


    def main():
        if IDLE_TIMEOUT > 0:
            threading.Thread(target=_idle_watchdog, daemon=True).start()

        # systemd sets LISTEN_FDS and hands the listening socket over as fd 3
        # (SD_LISTEN_FDS_START). Falling back to host/port keeps the command
        # runnable by hand for debugging.
        if os.environ.get("LISTEN_FDS"):
            where = {"fd": 3}
        else:
            where = {"host": "127.0.0.1", "port": 8000}

        uvicorn.run(_TouchOnRequest(app), timeout_keep_alive=30, **where)


    if __name__ == "__main__":
        main()
  '';
in
python3Packages.buildPythonApplication {
  pname = "withoutbg-inference";
  version = "3.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "withoutbg";
    repo = "withoutbg-inference";
    rev = "73bcf632dd018a8c284989b478c9d6f71301a714";
    hash = "sha256-f94KC9lNKyD/xQShRc639mw9fjfCfObCIM2hSA5kSXY=";
  };

  build-system = [ python3Packages.setuptools ];

  # Upstream pins onnxruntime==1.20.1, but only inside the `cpu`/`gpu` extras,
  # which we do not install -- nixpkgs' onnxruntime goes in directly. Nothing
  # here is version-sensitive: it opens an InferenceSession and calls run().
  dependencies =
    (with python3Packages; [
      fastapi
      numpy
      onnxruntime
      pillow
      python-multipart
      uvicorn
    ])
    # uvicorn[standard] in upstream's dependency list, and the dist-info check
    # hook verifies the extra is present, not just the base package.
    ++ python3Packages.uvicorn.optional-dependencies.standard;

  # Dropped in $out/bin so the Python wrap hook picks it up like a console
  # script and it gets the package's site-packages and the wrapper env below.
  postInstall = ''
    install -Dm755 ${serverScript} $out/bin/withoutbg-inference-server
  '';

  # config.py defaults the model to /opt/withoutbg/v3/model/, a path that only
  # exists inside upstream's images; point it at the shared store copy instead.
  makeWrapperArgs = [
    "--set"
    "WITHOUTBG_MODEL_PATH"
    "${withoutbg-open-weights}/withoutbg-open-weights.onnx"
  ];

  # The repo ships no Python tests.
  doCheck = false;
  pythonImportsCheck = [
    "withoutbg_api.main"
    "withoutbg_openweights.runtime"
  ];

  meta = {
    description = "Self-hosted withoutBG open-weights background removal HTTP API";
    homepage = "https://github.com/withoutbg/withoutbg-inference";
    license = lib.licenses.asl20;
    mainProgram = "withoutbg-inference-server";
    platforms = lib.platforms.linux;
  };
}
