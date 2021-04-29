with (import <nixpkgs> {});

let
  pkgs2003 = import
  (builtins.fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-20.03.tar.gz)
    { inherit config; };

  packages = rec {
    # The derivation for ctlptl
    ctlptl = buildGoModule rec {
      pname = "ctlptl";
      version = "0.5.1";

      src = fetchFromGitHub {
        owner = "tilt-dev";
        repo = "ctlptl";
        rev = "v${version}";
        sha256 =  "0658ck1zcqgh1ib5kjalvfxrfn5gqvbkpfx7c4d4af3dsavd5hwa";
      };

      vendorSha256 = "0kkmdp5ymli2h1x519v8zlpllbrmixwdyzq8kspqc278siwkbzc5";

      subPackages = [ "." ];

      runVend = false;

      installPhase = ''
        make install
        mkdir -p $out/bin/
        mv $GOPATH/bin/ctlptl $out/bin/
      '';

      meta = with lib; {
        description = "ctlptl cli";
        homepage = "https://github.com/tilt-dev/ctlptl";
        license = licenses.mit;
        # maintainers = with maintainers; [ kalbasit ];
        platforms = platforms.linux;
      };
    };

    # The derivation for kuberbuilder
    kubebuilder = buildGoModule rec {
      pname = "kubebuilder";
      version = "2.3.2";

      src = fetchFromGitHub {
        owner = "kubernetes-sigs";
        repo = "kubebuilder";
        rev = "v${version}";
        sha256 =  "10f48nmpkb3kx36x92a77mnrn48y6fvwq9dxlfw0r35hsrv1sm2g";
      };

      vendorSha256 = "079cnaflk2ap5fb357151fdqk7wr37dpghd3lmrmhcqwpfwp022m";

      subPackages = [ "." ];

      runVend = false;

      buildInputs = [
        git
      ];

      installPhase = ''
        mkdir -p $out/bin/
        export GOPATH=$out
        export GOBIN=$out/bin
        ls cmd
        make install
      '';

      meta = with lib; {
        description = "kubebuilder";
        homepage = "https://github.com/kubernetes-sigs/kubebuilder";
        license = licenses.mit;
        # maintainers = with maintainers; [ kalbasit ];
        platforms = platforms.linux;
      };
    };

    # The derivation for controller-gen
    controller-tools = buildGoModule rec {
      pname = "controller-tools";
      version = "0.5.0";

      src = pkgs.fetchurl {
        url = "https://github.com/kubernetes-sigs/controller-tools/archive/refs/tags/v0.5.0.tar.gz";
        sha256 = "002brbk3rq3wwggd5mm2vjqx2nc6xm40yqgp35wsrfw3vsm2x8i3";
      };

      vendorSha256 = "1dcswd3cvpvwc0fsh2mrbllb1i68pbdj0ml8c2kl9043552hi3s7";

      subPackages = [ "." ];

      runVend = false;

      installPhase = ''
        go build -o controller-gen cmd/controller-gen/main.go
        mkdir $out/bin -p
        mv controller-gen $out/bin/
      '';

      meta = with lib; {
        description = "ctlptl cli";
        homepage = "https://github.com/kubernetes-sigs/controller-tools";
        license = licenses.mit;
        # maintainers = with maintainers; [ kalbasit ];
        platforms = platforms.linux;
      };
    };

    # The derivation for kustomize
    kustomize3100 = stdenv.mkDerivation rec {
      pname = "kustomize";
      version = "3.10.0";

      src = pkgs.fetchurl {
        url = "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.10.0/kustomize_v3.10.0_linux_amd64.tar.gz";
        sha256 =  "1sph5zzim377r7z67cqfqhjsv1lrv1zngpsb2yx2k33ih64apd5s";
      };

      vendorSha256 = lib.fakeSha256;

      subPackages = [ "." ];

      runVend = false;

      unpackPhase = ''
        tar -xf $src
      '';

      installPhase = ''
        mkdir $out/bin -p
        mv kustomize $out/bin/
      '';

      meta = with lib; {
        description = "kustomize";
        homepage = "https://github.com/kubernetes-sigs/kustomize";
        license = licenses.mit;
        # maintainers = with maintainers; [ kalbasit ];
        platforms = platforms.linux;
      };
    };

    tiltEnv = mkShell rec {
      name = "tiltEnv";
      buildInputs = [
        tilt
        ctlptl
        kubebuilder
        controller-tools
        kind
        kubectl
        kustomize3100
        pkgs2003.go_1_13
      ];
    };
  };
in
packages
