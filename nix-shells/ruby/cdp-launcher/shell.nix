with (import <nixpkgs> {});

let
  pkgs = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/cd63096d6d887d689543a0b97743d28995bc9bc3.tar.gz) { };
  pkgs_old = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/f52505fac8c82716872a616c501ad9eff188f97f.tar.gz) { };
  pkgs_new = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/6d1934ae67198fda888f01d1642d8bd3cbe14bbb.tar.gz) { };
  gems = bundlerEnv {
    name = "cdp-launcher";
    ruby = pkgs.ruby;
    inherit (pkgs.ruby);
    gemdir = ./.;
    # gemfile = ./Gemfile;
    # lockfile = ./Gemfile.lock;
    gemset = (import ./gemset.nix) // {
     bundler = {
       groups = [ "development" "test" ];
       # platforms = [];
       source = {
         remotes = ["https://rubygems.org"];
         sha256 = "0h5j7974vhqjy97m7i22i19jmiyzw4hwv8s3qqr8dfkjnjc8v06a";
         type = "gem";
       };
       version = "2.2.16";
     };
    };
    groups = [ "development" "test" ];
    gemConfig.semian = attrs: {
      buildInputs = [ pkgs.openssl ];
    };
    gemConfig.charlock_holmes = attrs: {
      buildInputs = [ pkgs.gnumake pkgs.icu pkgs.pkgconfig pkgs.gcc pkgs.which pkgs.zlib ];
    };
    gemConfig.nokogiri = attrs: {
      buildInputs = [ pkgs.zlib pkgs.ruby ];
    };
    gemConfig.pg = attrs: {
      buildInputs = [ pkgs.postgresql ];
    };
    gemConfig.gpgme = attrs: {
      buildInputs = [ pkgs_old.gawk pkgs.gpgme pkgs.libgpgerror pkgs.libassuan ];
    };
    gemConfig.grpc = attrs: {
      buildInputs = [pkgs.pkg-config pkgs.gnumake pkgs.ruby pkgs.openssl pkgs.boringssl pkgs.grpc ];
    };
  };
in
pkgs_new.stdenv.mkDerivation {
  name = "clustering";

  buildInputs = [
    gems
    gems.ruby
    # pkgs.ruby
    pkgs_old.gawk
    pkgs.grpc
    pkgs.libgpgerror
    pkgs.libassuan
    pkgs_new.openssl
    pkgs.gpgme
    pkgs.bundix
    pkgs.icu
    pkgs.curl
    pkgs.sqlite
    pkgs.libpcap
    pkgs.zlib
    pkgs.postgresql
    pkgs.libxml2
    pkgs.libxslt
    pkgs.pkg-config
    pkgs.solargraph
    pkgs.rubyPackages_2_6.yard
    pkgs.rubocop
    pkgs.libpqxx
  ];
  BUNDLE_FROZEN="false";
  BUNDLE_PATH="/nix/store/jwjx55h1xsbg7xs60hn7xp4lk1vdbcgz-clustering";
  BUNDLE_BIN="/nix/store/jwjx55h1xsbg7xs60hn7xp4lk1vdbcgz-clustering/bin";

  shellHook = ''
    # solargraph download-core
    # yard config --gem-install-yri
    # yard doc
    # yard gems
  '';
}
