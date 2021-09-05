with (import <nixpkgs> {});

let
  mypkgs = import
  (builtins.fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/b5b7bd6ebba2a165e33726b570d7ab35177cf951.tar.gz)
    { inherit config; };
in
mypkgs.mkShell {
  buildInputs = [
    mypkgs.coq
    mypkgs.emacsPackages.proofgeneral_HEAD
  ];
}
