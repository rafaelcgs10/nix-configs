{ config, pkgs, lib, ... }:

{
  imports = [
    ../../programs/zsh/default.nix
    ../../programs/nvim/default.nix
  ];
}
