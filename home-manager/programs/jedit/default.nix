{ config, lib, pkgs, ... }:

let
  newer_isabelle_pkgs = import (builtins.fetchTarball {
    url = "https://github.com/jvanbruegge/nixpkgs/archive/fa28ed48582cb30afdce232a3313bb6fe32644e4.tar.gz";
  }) {};
in
{
  home.packages = with pkgs; [
    (isabelle.withComponents (p: [ p.isabelle-linter ]))
  ];
  home.file.".isabelle/Isabelle2022/jedit/properties".text = builtins.readFile ./properties;
# home.file.".isabelle/isabelle-linter" = {
#   source =  builtins.fetchTarball {
#     url = "https://github.com/isabelle-prover/isabelle-linter/archive/refs/tags/Isabelle2022-v1.2.1.tar.gz";
#     sha256 = "1rmafbba4hasxwkkg828jy5d05nlfyian5fh9qyzxpr65cs26nma";
#   };
# };
home.file.".isabelle/afp" = {
  source =  builtins.fetchTarball {
    url = "https://www.isa-afp.org/release/afp-current.tar.gz";
    sha256 = "0hsfnxd889igl4addfpdhvvp9jqq5n1l4790a521l2hp8kbii1p6";
  };
  # onChange =  "${pkgs.writeShellScript "afp-change" ''
  #   echo "/home/rafael/.isabelle/afp/thys" >  ~/.isabelle/Isabelle2022/etc/components
  # ''}";
};
home.file.".isabelle/Isabelle2022/etc/components".text = ''
      /home/rafael/.isabelle/afp/thys
  '';
}
