with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    coq
    emacsPackages.proofgeneral_HEAD
  ];
}
