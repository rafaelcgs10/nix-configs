# withoutbg: local (offline, CPU) background removal / alpha matting.
# https://github.com/withoutbg/withoutbg
#
# `withoutbg photo.jpg` writes photo-withoutbg.png with a real soft alpha
# channel -- it is a *matting* model, not a hard segmentation mask, so hair and
# motion blur come out with fractional alpha rather than a jagged cutout. The
# model is automatic salient-object matting at a fixed 448x448 input: there is
# no prompt, no click, no box. It finds "the subject" or it finds nothing.
#
# Not the same thing as the withoutbg GIMP plug-in, which is only an HTTP
# client for a separate withoutbg-inference server. This is the PyPI SDK, which
# runs the identical open-weights ONNX graph in-process, so no server, no
# Docker and nothing listening.
{
  lib,
  python3Packages,
  fetchurl,
  callPackage,
  withoutbg-open-weights ? callPackage ./withoutbg-open-weights.nix { },
}:

python3Packages.buildPythonApplication rec {
  pname = "withoutbg";
  version = "1.1.1";
  pyproject = true;

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/73/68/7071a058e6f42c88e154495fd04002ae4fc0bc221695a2e347f2e16f9fb9/withoutbg-${version}.tar.gz";
    hash = "sha256-FSgviA44U6UQDJOlaV3he9BMkYAq/VJIKGOyOTSkOwM=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = with python3Packages; [
    click
    huggingface-hub
    numpy
    onnxruntime
    pillow
    requests
    tqdm
  ];

  # models.py consults WITHOUTBG_MODEL_PATH before it considers Hugging Face,
  # so pointing it at the store copy makes the CLI fully offline. HF_HUB_OFFLINE
  # is belt and braces: if that lookup ever regresses, we want an immediate
  # error instead of a silent 455MB download on someone's tethered connection.
  makeWrapperArgs = [
    "--set"
    "WITHOUTBG_MODEL_PATH"
    "${withoutbg-open-weights}/withoutbg-open-weights.onnx"
    "--set-default"
    "HF_HUB_OFFLINE"
    "1"
  ];

  # The test suite's addopts hard-code --cov with an 80% floor, and the
  # integration tests reach out to Hugging Face; neither is worth carrying here.
  doCheck = false;
  pythonImportsCheck = [ "withoutbg" ];

  meta = {
    description = "Offline background removal and alpha matting with the withoutBG open-weights ONNX model";
    homepage = "https://github.com/withoutbg/withoutbg";
    # Apache-2.0 for both the SDK and the weights (the DINOv3 teacher used to
    # distil them carries its own licence, quoted in LICENSE-DINOv3).
    license = lib.licenses.asl20;
    mainProgram = "withoutbg";
    platforms = lib.platforms.linux;
  };
}
