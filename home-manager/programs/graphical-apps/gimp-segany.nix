# gimpsegany: click-to-select object segmentation in GIMP 3 via Segment
# Anything 2. Image > "Segment Anything Layers"; segmentation types are Auto
# (everything), Box (within a rectangle selection) or Selection (sample points
# from a selection) -- the last is the promptable, point-driven mode.
# https://github.com/Shriinivas/gimpsegany
#
# Paired with the SAM 2.1 *small* checkpoint, i.e. the same model darktable's
# AI object masking uses. Measured on this laptop (CPU, no CUDA): 2.4s to
# encode an image, then ~0.16s per click.
#
# The upstream install expects a pip-installed SAM in some Python the user
# browses to in the dialog. Nothing like that happens here: the plug-in and the
# inference bridge are separate processes with separate Nix Python envs, and
# the paths are pre-filled below, so it works with no manual setup.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  python3,
  # Checkpoints to install. All four together are ~1.5GB of weights; trim this
  # list if that is more store than you want.
  models ? [
    "tiny"
    "small"
    "base_plus"
    "large"
  ],
  # Which one the dialog starts on. Still switchable per run in the dialog.
  defaultModel ? "base_plus",
}:

let
  # GIMP side: gi/GTK only, no ML. Must match the Python nixpkgs builds GIMP's
  # own plug-ins with, because the shebang is what interprets the file.
  guiEnv = python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);

  # Bridge side: runs as a subprocess, so it is free to be a completely
  # separate env -- no version coupling with GIMP at all.
  bridgeEnv = python3.withPackages (ps: [
    ps.sam2
    ps.torch
    ps.numpy
    ps.opencv4
  ]);

  # SAM 2.1 checkpoints. Every model listed in `models` is installed side by
  # side, so switching is just picking another file in the dialog's "Checkpoint
  # Path" browser -- no rebuild needed. Larger models separate touching or
  # overlapping objects better; `small` is the one darktable uses.
  allCheckpoints = {
    tiny = "sha256-dALg2GT6gnCKIPvRW8hCRcLybf8OtDpLW5NFLes0vmk=";
    small = "sha256-bRqm8w3lySIk+BchFN4IHRBLvSPdncXFiZbwytXcTTg=";
    base_plus = "sha256-ojRa7ehxWrHV0xtKUJ+xYMWkrxlw8ZnZBUzPt0bABMU=";
    large = "sha256-JkeHjV36UJjy+GSYJXOKk0VXK64tQ1CiRoWH7OR90xg=";
  };

  installedCheckpoints = lib.genAttrs models (
    name:
    fetchurl {
      url = "https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_${name}.pt";
      hash = allCheckpoints.${name};
    }
  );
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gimp-segany";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/Shriinivas/gimpsegany/releases/download/v${finalAttrs.version}/gimp-segany-gimp3.zip";
    hash = "sha256-kzb91AknjmRYeon2g645sEj82y08v4JAOYVRA2yZpEY=";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = "seganyplugin";

  dontBuild = true;
  # Shebangs are set explicitly below; the default hook would rewrite them to
  # whatever python is in the build PATH, which is neither of the envs above.
  dontPatchShebangs = true;

  postPatch = ''
    # 1. The bridge imports SAM1 unconditionally, but only *uses* those symbols
    #    in its SAM1 code paths. segment-anything (SAM1) is not in nixpkgs, so
    #    make the import optional rather than packaging a model we never load.
    substituteInPlace seganybridge.py \
      --replace-fail \
        "from segment_anything import (
    sam_model_registry,
    SamAutomaticMaskGenerator as SamAutomaticMaskGenerator_SAM1,
    SamPredictor,
)" \
        "try:
    from segment_anything import (
        sam_model_registry,
        SamAutomaticMaskGenerator as SamAutomaticMaskGenerator_SAM1,
        SamPredictor,
    )
except ImportError:  # SAM1 unavailable; only the SAM2 paths below are reachable
    sam_model_registry = None
    SamAutomaticMaskGenerator_SAM1 = None
    SamPredictor = None"

    # 2. Upstream collapses every SAM 2.1 checkpoint onto the SAM 2.0 configs,
    #    so a 2.1 file fails to load with "Unexpected key(s) in state_dict:
    #    no_obj_embed_spatial, obj_ptr_tpos_proj.*". Keep the 2.1 names distinct
    #    and give them the matching configs/sam2.1/ YAMLs. SAM 2.0 checkpoints
    #    keep working, so a hand-picked one in the dialog still loads.
    substituteInPlace seganybridge.py \
      --replace-fail \
        '"sam2.1_hiera_large": "sam2_hiera_large",
        "sam2.1_hiera_base_plus": "sam2_hiera_base_plus",
        "sam2.1_hiera_small": "sam2_hiera_small",
        "sam2.1_hiera_tiny": "sam2_hiera_tiny",' \
        '"sam2.1_hiera_large": "sam2.1_hiera_large",
        "sam2.1_hiera_base_plus": "sam2.1_hiera_base_plus",
        "sam2.1_hiera_small": "sam2.1_hiera_small",
        "sam2.1_hiera_tiny": "sam2.1_hiera_tiny",' \
      --replace-fail \
        '"sam2_hiera_large": "sam2_hiera_l.yaml",
        }' \
        '"sam2_hiera_large": "sam2_hiera_l.yaml",
            "sam2.1_hiera_tiny": "configs/sam2.1/sam2.1_hiera_t.yaml",
            "sam2.1_hiera_small": "configs/sam2.1/sam2.1_hiera_s.yaml",
            "sam2.1_hiera_base_plus": "configs/sam2.1/sam2.1_hiera_b+.yaml",
            "sam2.1_hiera_large": "configs/sam2.1/sam2.1_hiera_l.yaml",
        }'

    # 3. The model dropdown only lists SAM 2.0 names, so picking one explicitly
    #    (rather than leaving "Auto") still selects a 2.0 config and the 2.1
    #    checkpoint fails to load -- silently, leaving an empty layer group.
    #    Derive the config from the checkpoint's own filename instead, which is
    #    correct no matter what the dropdown says.
    substituteInPlace seganybridge.py \
      --replace-fail \
        'config_file = model_configs.get(modelType, "sam2_hiera_l.yaml")' \
        'config_file = model_configs.get(modelType, "sam2_hiera_l.yaml")
        _bn = os.path.basename(checkPtFilePath)
        _size = next(
            (sz for sz in ("base_plus", "large", "small", "tiny") if sz in _bn), None
        )
        if "sam2" in _bn and _size is not None:
            _abbr = {"tiny": "t", "small": "s", "base_plus": "b+", "large": "l"}[_size]
            config_file = (
                "configs/sam2.1/sam2.1_hiera_%s.yaml" % _abbr
                if "sam2.1" in _bn
                else "sam2_hiera_%s.yaml" % _abbr
            )'

    # 4. sam2's build_sam2() defaults to device="cuda", and the bridge never
    #    passes one -- it only guards the *later* .to("cuda"). On a CPU-only
    #    torch (what nixpkgs ships) that aborts with "Torch not compiled with
    #    CUDA enabled" before the model ever loads.
    substituteInPlace seganybridge.py \
      --replace-fail \
        'sam = build_sam2(config_file, actual_checkpoint_path)' \
        'sam = build_sam2(
                config_file,
                actual_checkpoint_path,
                device=("cuda" if torch.cuda.is_available() else "cpu"),
            )'

    # 5. Settings are persisted next to the plug-in, which is read-only here.
    #    Move them to XDG_STATE_HOME. (Masks already go to tempfile.gettempdir,
    #    so they need no patching.)
    substituteInPlace seganyplugin.py \
      --replace-fail \
        'scriptDir = os.path.dirname(os.path.abspath(__file__))
        self.configFilePath = os.path.join(scriptDir, "segany_settings.json")' \
        'stateDir = os.path.join(os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "gimp-segany")
        os.makedirs(stateDir, exist_ok=True)
        self.configFilePath = os.path.join(stateDir, "segany_settings.json")'

    # 6. Pre-fill the two paths the dialog would otherwise make the user browse
    #    for. Both remain editable in the dialog and are persisted per-user.
    # The bridge's "Auto" model detection reads the checkpoint's FILE NAME and
    # requires it to start with "sam2" -- a bare store path starts with the
    # hash, so it is linked under its real name in installPhase and pointed at
    # here.
    substituteInPlace seganyplugin.py \
      --replace-fail 'self.pythonPath = None' 'self.pythonPath = "${bridgeEnv}/bin/python3"' \
      --replace-fail 'self.checkPtPath = None' 'self.checkPtPath = "${placeholder "out"}/sam2.1_hiera_${defaultModel}.pt"'
  '';

  # GIMP loads <plug-ins>/<name>/<name>.py, executable; $out is that directory.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    install -Dm755 seganyplugin.py $out/seganyplugin.py
    install -Dm644 seganybridge.py $out/seganybridge.py
    substituteInPlace $out/seganyplugin.py \
      --replace-fail '#!/usr/bin/env python3' '#!${guiEnv}/bin/python3'
    ${lib.concatMapStringsSep "\n    " (
      m: "ln -s ${installedCheckpoints.${m}} $out/sam2.1_hiera_${m}.pt"
    ) models}

    runHook postInstall
  '';

  meta = {
    description = "GIMP 3 plug-in for object selection with Segment Anything 2";
    homepage = "https://github.com/Shriinivas/gimpsegany";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
})
