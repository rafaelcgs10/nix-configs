let
  unstable = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/93184413f2180ce79d53df91df4d43c2e8f931aa.tar.gz) { };
in
unstable.mkShell {
  buildInputs = [
    unstable.python38Full
    unstable.python38Packages.scrapy
    unstable.python38Packages.python-language-server
  ];
}
