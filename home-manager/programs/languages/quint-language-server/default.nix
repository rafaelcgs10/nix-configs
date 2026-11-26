# The Quint language server (diagnostics, hover, go to definition, completion),
# for eglot in Doom; not in nixpkgs. Built from the npm release, which ships
# compiled JavaScript. package-lock.json pins its runtime dependencies; it was
# generated from the release's package.json without devDependencies and
# scripts, which postPatch strips the same way. To update: bump version and
# hash, regenerate the lock (npm install --package-lock-only --ignore-scripts
# on the stripped package.json), then refresh npmDepsHash with
# prefetch-npm-deps package-lock.json.
{ buildNpmPackage, fetchurl, jq }:

buildNpmPackage rec {
  pname = "quint-language-server";
  version = "0.19.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@informalsystems/quint-language-server/-/quint-language-server-${version}.tgz";
    hash = "sha256-gNoz7Pu+/TO/Vp86IB8tfZ9vHN78L7eRllITNtsnGFY=";
  };

  postPatch = ''
    ${jq}/bin/jq 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-vAJ0MhnRX66Ew0JkYCw1gBL/Gk8lqSGyBnPrmhtfJrc=";
  dontNpmBuild = true;

  meta.mainProgram = "quint-language-server";
}
