# Arakne's Path Shape Creator: generates vector paths/shapes (arches, stars,
# frames, rays, letters, ...) as GIMP paths. GIMP 3 only.
# https://www.arakne.es/en/gimp-plugin-shape-creator-2026/
#
# Not packaged anywhere (no nixpkgs entry, and upstream has no git repo at all
# -- it is distributed only as dated ZIPs from the author's site), so the URL
# and hash have to be bumped by hand when a new dated build appears on that
# page. The source carries GPL-3.0-or-later headers even though the page states
# no license.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  python3,
}:

let
  # Pure PyGObject plug-in -- no third-party Python deps. This must be the same
  # Python nixpkgs builds GIMP's own plug-ins with (the default python3), since
  # the shebang below is what actually interprets the file.
  pythonEnv = python3.withPackages (ps: [
    ps.pygobject3
    ps.pycairo
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gimp-path-shape-creator";
  version = "2026-07-02";

  src = fetchurl {
    url = "https://www.arakne.es/wp-content/uploads/2026/04/path-shape-creator-${finalAttrs.version}.zip";
    hash = "sha256-av6mvnIw1OCliW7nlYJhFxk2TtEKk0vOuQDDyBrLgWs=";
  };

  nativeBuildInputs = [ unzip ];
  sourceRoot = "path-shape-creator-2026";

  dontBuild = true;
  # The shebang is rewritten deliberately in installPhase; the default hook
  # would point it at whatever python is in the build PATH, which has no gi.
  dontPatchShebangs = true;

  # The plug-in keeps mutable state next to itself: it truncates
  # arakneshapes/errors.txt at import time (and redirects stdout/stderr into
  # it), and saves the shape presets as arakneshapes/shapes.json. Both are
  # impossible under /nix/store -- the errors.txt one would abort the import and
  # the plug-in would never register. Point that state at XDG_STATE_HOME
  # instead; fPath itself is left alone because it is also the module search
  # path and the shapesImg location, which must stay in the store.
  #
  # shapes.json is shipped in the ZIP and holds the DEFAULT presets, not just
  # user state: the dialog does defs=shelf.read_all() then defs['lastshape'],
  # and GimpShelf.read_all() returns None when the file is missing -- so a bare
  # redirect makes the dialog die with a TypeError before it is ever shown.
  # Seed the state copy from the packaged one on first use.
  postPatch = ''
    substituteInPlace path-shape-creator-2026.py \
      --replace-fail \
        "fPath = os.path.join(os.path.dirname(__file__), \"arakneshapes\")" \
        "fPath = os.path.join(os.path.dirname(__file__), \"arakneshapes\")

def _arakneState(name):
    import shutil
    d = os.path.join(os.environ.get(\"XDG_STATE_HOME\", os.path.expanduser(\"~/.local/state\")), \"arakne-shape-creator\")
    os.makedirs(d, exist_ok=True)
    p = os.path.join(d, name)
    if not os.path.exists(p):
        src = os.path.join(os.path.dirname(__file__), \"arakneshapes\", name)
        if os.path.exists(src):
            shutil.copyfile(src, p)
    return p" \
      --replace-fail \
        "open(fPath + os.sep + \"errors.txt\", 'w').close()" \
        "open(_arakneState(\"errors.txt\"), 'w').close()" \
      --replace-fail \
        "sys.stderr = open(fPath + os.sep + \"errors.txt\",'a')" \
        "sys.stderr = open(_arakneState(\"errors.txt\"),'a')" \
      --replace-fail \
        "shelf=GimpShelf(fPath + os.sep + \"shapes.json\")" \
        "shelf=GimpShelf(_arakneState(\"shapes.json\"))"
  '';

  # GIMP loads <plug-ins>/<name>/<name>.py, executable -- $out is that
  # directory, so it can be symlinked straight into the plug-ins dir.
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r . $out/
    chmod +x $out/path-shape-creator-2026.py
    substituteInPlace $out/path-shape-creator-2026.py \
      --replace-fail '#!/usr/bin/env python3' '#!${pythonEnv}/bin/python3'

    runHook postInstall
  '';

  meta = {
    description = "GIMP 3 plug-in generating vector shapes and arches as paths";
    homepage = "https://www.arakne.es/en/gimp-plugin-shape-creator-2026/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
})
