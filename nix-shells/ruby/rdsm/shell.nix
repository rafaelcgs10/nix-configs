with (import <nixpkgs> {});

let
  pkgs = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/cd63096d6d887d689543a0b97743d28995bc9bc3.tar.gz) { };
  pkgs_old = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/f52505fac8c82716872a616c501ad9eff188f97f.tar.gz) { };
  gems = bundlerEnv {
    name = "rdsm";
    ruby = pkgs.ruby_2_6;
    inherit (pkgs.ruby_2_6);
    gemdir = ./vendor/cache;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
    groups = [ "development" "test" ];
    gemConfig.semian = attrs: {
      buildInputs = [ pkgs.openssl ];
    };
    gemConfig.charlock_holmes = attrs: {
      buildInputs = [ pkgs.gnumake pkgs.icu pkgs.pkgconfig pkgs.gcc pkgs.which pkgs.zlib ];
    };
    gemConfig.nokogiri = attrs: {
      buildInputs = [ pkgs.zlib pkgs.ruby_2_6 ];
    };
    gemConfig.pg = attrs: {
      buildInputs = [ pkgs.postgresql ];
    };
  };
in
mkShell {
  name = "rdsm";
  buildInputs = [
    gems
    pkgs.git
    pkgs.ruby_2_6
    pkgs.grpc
    pkgs_old.gawk
    pkgs.libgpgerror
    pkgs.libassuan
    pkgs.gpgme
    pkgs.icu
    pkgs.curl
    pkgs.bundix
    pkgs.sqlite
    pkgs.libpcap
    # pkgs.postgresql
    pkgs.libxml2
    pkgs.libxslt
    pkgs.pkg-config
    pkgs.gnumake
    pkgs.libpqxx
    rubyPackages.curb
  ];
}
