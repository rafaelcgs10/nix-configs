{ config, lib, pkgs, pkgsIsabelle, ... }:

{
  home.packages = with pkgsIsabelle; [
    (isabelle)
    # (isabelle.withComponents (p: [ p.isabelle-linter ]))
  ];
  # home.file.".isabelle/Isabelle2025-2/jedit/properties".text = builtins.readFile ./properties;
# home.file.".isabelle/isabelle-linter" = {
#   source =  builtins.fetchTarball {
#     url = "https://github.com/isabelle-prover/isabelle-linter/archive/refs/tags/Isabelle2022-v1.2.1.tar.gz";
#     sha256 = "1rmafbba4hasxwkkg828jy5d05nlfyian5fh9qyzxpr65cs26nma";
#   };
# };
# home.file.".isabelle/afp" = {
#   source =  builtins.fetchTarball {
#     url = "https://www.isa-afp.org/release/afp-current.tar.gz";
#     sha256 = "0k5a9w2gqzlp5cxm71dj4xddbni7p063x7pdxwyn86jdrbwqm1b4";
#   };
# };
home.file.".isabelle/Isabelle2025-2/etc/components".text = ''
      /home/rafael/.isabelle/afp/thys
  '';
}
