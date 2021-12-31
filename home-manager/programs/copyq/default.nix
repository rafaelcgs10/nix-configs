{ pkgs, ...}:

{
  home.packages = [ pkgs.copyq ];
  home.file.".config/copyq/copyq.conf".text = builtins.readFile ./copyq.conf;
}
