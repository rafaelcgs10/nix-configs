# The withoutBG open-weights matting model (Apache-2.0), as a directory holding
# the ONNX graph and its sidecar metadata under their upstream file names.
#
# Shared by withoutbg.nix (the SDK/CLI) and withoutbg-inference.nix (the HTTP
# server the GIMP plug-in talks to): both read WITHOUTBG_MODEL_PATH, and both
# derive the sidecar path as <model path> + ".json", i.e. strictly *next to*
# the .onnx -- hence one directory rather than two loose fetchurls. Sharing it
# also keeps a single 455MB copy in the store instead of one per consumer.
#
# The sidecar is not optional: canvas_size / input_name / output_shape come
# from it, and withoutbg-inference additionally verifies the .onnx against the
# sha256 recorded there before it will serve anything.
{
  fetchurl,
  linkFarm,
}:

let
  # Pinned to the model repo's commit rather than "main" so a silent upstream
  # reupload cannot change what we build.
  rev = "cfae4da1ee09b27c45af2af2096d4d14721508ba";
  url = name: "https://huggingface.co/withoutbg/withoutbg-openweights-onnx/resolve/${rev}/${name}";
in
linkFarm "withoutbg-open-weights" {
  "withoutbg-open-weights.onnx" = fetchurl {
    url = url "withoutbg-open-weights.onnx";
    hash = "sha256-KZMOSOnV7MVtZIbFPDWkwUcFZsKjNZ+hgLCMjTw07w8=";
  };
  "withoutbg-open-weights.onnx.json" = fetchurl {
    url = url "withoutbg-open-weights.onnx.json";
    hash = "sha256-bLeAA17k+ed7QLzQ2GjB61d513w+82MrJm0peDcojio=";
  };
}
