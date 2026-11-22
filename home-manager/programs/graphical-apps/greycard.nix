# greycard (https://greycard.org), a scene-referred raw editor. Not in
# nixpkgs, NUR or any flake (checked 2026-11-22), so this repackages the
# official prebuilt Linux tarball; nothing is compiled. A source build needs
# Rust 1.98 (nixpkgs: 1.95) and its ort crate downloads a WebGPU ONNX
# Runtime at build time.
#
# The tarball's binaries need only fontconfig and libstdc++ at link time;
# Vulkan, Wayland, xkbcommon, EGL/GL and X11 are dlopen'ed by name, so they
# go in runtimeDependencies (autoPatchelf adds them to every RUNPATH).
# greycard looks for libonnxruntime.so beside its own executable (and ONNX
# Runtime finds libwebgpu_dawn.so beside itself), so all four files stay
# together in lib/greycard, with bin/ symlinks: the executable path it
# resolves is the real one in lib/greycard.
#
# Update: pick a release from https://github.com/jessolmstead/greycard/releases,
# bump `version`, and take the tarball's line from that release's SHA256SUMS:
#   nix hash convert --hash-algo sha256 --to sri <hex>
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  fontconfig,
  vulkan-loader,
  wayland,
  libxkbcommon,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxcb,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "greycard";
  version = "0.12.0";

  src = fetchurl {
    url = "https://github.com/jessolmstead/greycard/releases/download/v${finalAttrs.version}/greycard-${finalAttrs.version}-x86_64-linux.tar.gz";
    hash = "sha256-gMgSJMI83pNrHjsB+BaQsp4yQsScJ8cW19ZnZjsfmcc=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    fontconfig
    stdenv.cc.cc.lib
  ];
  runtimeDependencies = [
    vulkan-loader
    wayland
    libxkbcommon
    libGL
    libx11
    libxcursor
    libxi
    libxcb
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/lib/greycard bin/greycard bin/greycard-ui
    install -Dm644 -t $out/lib/greycard bin/libonnxruntime.so bin/libwebgpu_dawn.so
    mkdir -p $out/bin
    ln -s ../lib/greycard/greycard $out/bin/greycard
    ln -s ../lib/greycard/greycard-ui $out/bin/greycard-ui
    cp -r share $out/share
    install -Dm644 -t $out/share/doc/greycard README.md LICENSE THIRD-PARTY-NOTICES
    runHook postInstall
  '';

  meta = {
    description = "Scene-referred, color-managed raw photo editor";
    homepage = "https://greycard.org";
    changelog = "https://github.com/jessolmstead/greycard/blob/master/docs/changelog.md";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "greycard-ui";
    platforms = [ "x86_64-linux" ];
  };
})
