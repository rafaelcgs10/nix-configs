{
  a3s-client = {
    dependencies = ["a3s-model" "google-protobuf" "googleapis-common-protos-types" "microservice-toolkit" "platform-model" "typhoeus"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1ynfnbbpdbqc89fv3px23vih5ph3rwx230vym84zm6vs8khxflbs";
      type = "gem";
    };
    version = "1.31.0";
  };
  a3s-model = {
    dependencies = ["google-protobuf" "googleapis-common-protos-types" "platform-model"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1qjbnhjkp20k8bw37b3zzvqqmccia2fqwbrd5a87grz7q8z1813f";
      type = "gem";
    };
    version = "1.30.2";
  };
  actioncable = {
    dependencies = ["actionpack" "activesupport" "nio4r" "websocket-driver"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "15r6ab17iwhhq92by4ah9z4wwvjbr07qn16x8pn2ypgqwvfy74h7";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  actionmailbox = {
    dependencies = ["actionpack" "activejob" "activerecord" "activestorage" "activesupport" "mail"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1q1r3x9fbq5wlgn4xhqw48la09q7f97zna7ld5fglk3jpmh973x5";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  actionmailer = {
    dependencies = ["actionpack" "actionview" "activejob" "activesupport" "mail" "rails-dom-testing"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1nqdaykzgib8fsldkxdkw0w44jzz4grvb028crzg0qpwvv03g2wp";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  actionpack = {
    dependencies = ["actionview" "activesupport" "rack" "rack-test" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1wdgv5llgbl4nayx5j78lfvhhjssrzfmypb45mjy37mgm8z5l5m5";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  actiontext = {
    dependencies = ["actionpack" "activerecord" "activestorage" "activesupport" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1zfrkcnp9wy1dm4b6iqf29858dp04a62asfmldainqmv4a7931q7";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  actionview = {
    dependencies = ["activesupport" "builder" "erubi" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1r6db2g3fsrca1hp9kbyvjx9psipsxw0g306qharkcblxl8h1ysn";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  active_model_serializers = {
    dependencies = ["actionpack" "activemodel" "case_transform" "jsonapi-renderer"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1jjkmrx82rn0d2bhpi6kz2h1s4w7rpk5pj2vcssyc1a2ys12vyhj";
      type = "gem";
    };
    version = "0.10.12";
  };
  activejob = {
    dependencies = ["activesupport" "globalid"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0p80rbahcxhxlkxgf4bh580hbifn9q4gr5g9fy8fd0z5g6gr9xxq";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  activemodel = {
    dependencies = ["activesupport"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1gpd3hh4ryyr84drj6m0b5sy6929nyf50bfgksw1hpc594542nal";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  activemodel-serializers-xml = {
    dependencies = ["activemodel" "activesupport" "builder"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1pk5qrxxhgxlihim8qkdk805nq584ms71hmcg1766iwhx0v2x3r2";
      type = "gem";
    };
    version = "1.0.2";
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0fg58qma2zgrz0gr61p61qcz8c3h88fd5lbdrkpkm96aq5shwh68";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  activestorage = {
    dependencies = ["actionpack" "activejob" "activerecord" "activesupport" "marcel" "mini_mime"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0sbpkk3r8qi47bd0ilznq4gpfyfwm2bwvxqb5z0wc75h3zj1jhqg";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  activesupport = {
    dependencies = ["concurrent-ruby" "i18n" "minitest" "tzinfo" "zeitwerk"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1csxddyhl6k773ycxjvmyshyr4g9jb1icbs3pnm7crnavqs4h1yr";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1fvchp2rhp2rmigx7qglf69xvjqvzq7x0g49naliw29r2bz656sy";
      type = "gem";
    };
    version = "2.7.0";
  };
  advanced_analytics_client = {
    dependencies = ["microservice-toolkit"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "15n5xaij11p40zlqhpdzxn7wrn8nlq8sgn7s822wjs9sr0386glk";
      type = "gem";
    };
    version = "0.3.4";
  };
  agendor-ruby = {
    dependencies = ["faraday" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "e84526a339a6b37e4e01a9b886eb362b09f7f24b";
      sha256 = "0kzn20ba6lnlcqg4waayil803azrmh8h0siz2s4rrjdmbbrad6jx";
      type = "git";
      url = "https://github.com/resultadosdigitais/agendor-ruby";
    };
    version = "2.5.0";
  };
  akami = {
    dependencies = ["gyoku" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "168y57kd9wshzqqk127w7lknd8lr0b9k50wazw4c92zshq3sw2jd";
      type = "gem";
    };
    version = "1.3.1";
  };
  analytics-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1h7fyvhnj6fzqc8wds0z769zxyy3y8c8gfm5d9qpih9kwblir83m";
      type = "gem";
    };
    version = "2.0.13";
  };
  anyway_config = {
    dependencies = ["ruby-next-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0qd5ykwm5y6jcfm0abdxc16asgfn1ync7rg38hjxlrshv5khn58l";
      type = "gem";
    };
    version = "2.1.0";
  };
  api-auth = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0l16gr306a00wk49qg4zrcix07qgfyacard59gfd4xaq9ixbgjca";
      type = "gem";
    };
    version = "2.1.0";
  };
  ast = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      type = "gem";
    };
    version = "2.4.2";
  };
  auth0 = {
    dependencies = ["rest-client"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "187b7yhdd522f6zx6ny50857g9wyfjcwi4f07ic9bymm0aj1wd21";
      type = "gem";
    };
    version = "4.11.0";
  };
  auth0-toolkit = {
    dependencies = ["a3s-client" "faraday" "jwt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1gji7gh40i9540rsqzi6zwbdyz75zbgqdmn2p4r35kdi99yyxvni";
      type = "gem";
    };
    version = "1.8.15";
  };
  automation = {
    groups = ["default"];
    platforms = [];
    source = {
      path = components/automation;
      type = "path";
    };
    version = "0.0.1";
  };
  autoprefixer-rails = {
    dependencies = ["execjs"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1vlqwy2qkp39ibp7llj7ps53nvxav29c2yl451v1qdhj25zxc49p";
      type = "gem";
    };
    version = "10.2.5.1";
  };
  awesome_print = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0vkq6c8y2jvaw03ynds5vjzl1v9wg608cimkd3bidzxc0jvk56z9";
      type = "gem";
    };
    version = "1.9.2";
  };
  aws-eventstream = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0jfki5ikfr8ln5cdgv4iv1643kax0bjpp29jh78chzy713274jh3";
      type = "gem";
    };
    version = "1.1.1";
  };
  aws-partitions = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0fs3fy6k4wmzh0z6c4rl313f5px81pj0viqxj1prksza4j7iymmi";
      type = "gem";
    };
    version = "1.465.0";
  };
  aws-sdk-cloudfront = {
    dependencies = ["aws-sdk-core" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0xk2qp5r8zhfi2xc05rksiykkjna1agkwiz8g6xfhdblyrzwz3xw";
      type = "gem";
    };
    version = "1.22.1";
  };
  aws-sdk-core = {
    dependencies = ["aws-eventstream" "aws-partitions" "aws-sigv4" "jmespath"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "09ksnsj7jqb339fy4nh6v8zn9gy77vbyjpsiv33r35q82ivi32z2";
      type = "gem";
    };
    version = "3.114.1";
  };
  aws-sdk-kms = {
    dependencies = ["aws-sdk-core" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "01pd0f4srsa65zl4zq4014p9j5yrr2yy9h9ab17g3w9d0qqm2vsh";
      type = "gem";
    };
    version = "1.43.0";
  };
  aws-sdk-s3 = {
    dependencies = ["aws-sdk-core" "aws-sdk-kms" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "14iv2wqvvbiz0gdms21i9n6rh8390r1yg4zcf8pzzfplbqfwqw4w";
      type = "gem";
    };
    version = "1.48.0";
  };
  aws-sdk-sqs = {
    dependencies = ["aws-sdk-core" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0pszp0bcgiqn4iskb6xv5j2n540h1k9glz2w85vq5iml1casq769";
      type = "gem";
    };
    version = "1.22.0";
  };
  aws-sigv4 = {
    dependencies = ["aws-eventstream"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1d9zhmi3mpfzkkpg7yw7s9r1dwk157kh9875j3c7gh6cy95lmmaw";
      type = "gem";
    };
    version = "1.2.3";
  };
  backports = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0xqvwj3mm28g1z4npya51zjcvxaniyyzn3fwgcdwmm8xrdbl8fgr";
      type = "gem";
    };
    version = "3.21.0";
  };
  basic_analytics_client = {
    dependencies = ["microservice-toolkit"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "07xqcpkp23kyim4zd00vpf3ycnb05nr4sv0c6hibrizmw8a9pjpi";
      type = "gem";
    };
    version = "1.29.0";
  };
  benchmark-memory = {
    dependencies = ["memory_profiler"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "11qw8k6rl79ri00njrf1x9v6vzwgv12rkcvgzvg0sk8pfrkzwyxa";
      type = "gem";
    };
    version = "0.1.2";
  };
  better_errors = {
    dependencies = ["coderay" "erubi" "rack"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "11220lfzhsyf5fcril3qd689kgg46qlpiiaj00hc9mh4mcbc3vrr";
      type = "gem";
    };
    version = "2.9.1";
  };
  better_html = {
    dependencies = ["actionview" "activesupport" "ast" "erubi" "html_tokenizer" "parser" "smart_properties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1sssv94gg7bnxiqn5pbbpf8rdnmw3iyj2qwn2pbgxxs8xmmq158b";
      type = "gem";
    };
    version = "1.0.16";
  };
  binding_of_caller = {
    dependencies = ["debug_inspector"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "078n2dkpgsivcf0pr50981w95nfc2bsrp3wpf9wnxz1qsp8jbb9s";
      type = "gem";
    };
    version = "1.0.0";
  };
  bitly = {
    dependencies = ["httparty" "multi_json" "oauth2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0lmsm1vx9wz3lc6vpp3082sxv9zxrh1w8w94jgr24d9czf5iycjv";
      type = "gem";
    };
    version = "0.10.4";
  };
  bootsnap = {
    dependencies = ["msgpack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "12n09iwpssnsfw9s140ynfxr9psd0xcfx42yqdsk0hq60zhq2nlx";
      type = "gem";
    };
    version = "1.7.5";
  };
  bootstrap-sass = {
    dependencies = ["autoprefixer-rails" "sassc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1py78mv97c1m2w59s1h7fvs34j4hh66yln5275537a5hbr9p6ims";
      type = "gem";
    };
    version = "3.4.1";
  };
  bootstrap-tour-rails = {
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "6e9c2cf0d7004bf774cea231f2b3eb0bd35e9001";
      sha256 = "0gx1h85psp6bbzgx2hpl8yakizinmisiwj1f20f3i609wv7wznhg";
      type = "git";
      url = "https://github.com/tienle/bootstrap-tour-rails.git";
    };
    version = "0.11.0";
  };
  brakeman = {
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0cdlfdaj3p9s1mck8zax35g524szs1danjrah8da3z7c8xvpq6sc";
      type = "gem";
    };
    version = "5.0.1";
  };
  bricks_manager = {
    dependencies = ["activerecord" "pg"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "be127ac3060220ea8f2847cef6bd095272c1511e";
      sha256 = "0c6zn571cb7bl4r9chx34fcg1pn16skclfgm9lblsaq880k8jnmj";
      type = "git";
      url = "https://github.com/ResultadosDigitais/bricks_manager.git";
    };
    version = "0.2.0";
  };
  bson = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0pnr0b7phdzhkw9xqhmqnw5673ndi13ks3dqwqmbxq6v0rsxiapc";
      type = "gem";
    };
    version = "4.12.1";
  };
  buftok = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1rzsy1vy50v55x9z0nivf23y0r9jkmq6i130xa75pq9i8qrn1mxs";
      type = "gem";
    };
    version = "0.2.0";
  };
  builder = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "045wzckxpwcqzrjr353cxnyaxgf0qg22jh00dcx7z38cys5g1jlr";
      type = "gem";
    };
    version = "3.2.4";
  };
  byebug = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0nx3yjf4xzdgb8jkmk2344081gqr22pgjqnmjg2q64mj5d6r9194";
      type = "gem";
    };
    version = "11.1.3";
  };
  capybara = {
    dependencies = ["addressable" "mini_mime" "nokogiri" "rack" "rack-test" "regexp_parser" "xpath"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1viqcpsngy9fqjd68932m43ad6xj656d1x33nx9565q57chgi29k";
      type = "gem";
    };
    version = "3.35.3";
  };
  capybara-screenshot = {
    dependencies = ["capybara" "launchy"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1k847fn9vlzpakl2ydq4pphcnc9bkgrdc2r67p2a18sn30l3j50q";
      type = "gem";
    };
    version = "1.0.25";
  };
  caronte-client = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0cmc9f1pr6cvmhaj4xrs0jhh7mqhcd04idfzw5x9x0p1lkbnfkag";
      type = "gem";
    };
    version = "0.1.1";
  };
  carrierwave = {
    dependencies = ["activemodel" "activesupport" "addressable" "image_processing" "marcel" "mini_mime" "ssrf_filter"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0qqs6pggzx6bvf68wbp8fiqaj4x0b8b81riakn6xjks5gaaqn4j6";
      type = "gem";
    };
    version = "2.2.2";
  };
  case_transform = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0fzyws6spn5arqf6q604dh9mrj84a36k5hsc8z7jgcpfvhc49bg2";
      type = "gem";
    };
    version = "0.2";
  };
  caxlsx = {
    dependencies = ["htmlentities" "marcel" "nokogiri" "rubyzip"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1lx0dh0m1wnwqyf4ixvxkvdgim4rlmh5i5if624hj4z6mwlhpn70";
      type = "gem";
    };
    version = "3.1.0";
  };
  cdp-schema_client = {
    dependencies = ["json" "microservice-toolkit" "typhoeus" "valid_kit"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "02sd0flbcxh3l6pz8x14mvrxclbbfqay46cwb2m29c5g47flys09";
      type = "gem";
    };
    version = "3.8.0";
  };
  cdp-sdk = {
    dependencies = ["cdp-schema_client" "google-protobuf" "grpc" "platform-model" "timeline-swagger-client" "valid_kit"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "13cpkbdspskdkc602fy96rzlsnmadlk5p3prdx09isghcqb1hir5";
      type = "gem";
    };
    version = "0.4.0";
  };
  charlock_holmes = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0hybw8jw9ryvz5zrki3gc9r88jqy373m6v46ynxsdzv1ysiyr40p";
      type = "gem";
    };
    version = "0.7.7";
  };
  childprocess = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1ic028k8xgm2dds9mqnvwwx3ibaz32j8455zxr9f4bcnviyahya5";
      type = "gem";
    };
    version = "3.0.0";
  };
  cliver = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "096f4rj7virwvqxhkavy0v55rax10r4jqf8cymbvn4n631948xc7";
      type = "gem";
    };
    version = "0.3.2";
  };
  clustering-engine-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "11yfk55l2mpqv4651nr68g12zdldgx1si2pxrgnya03vyn754rhn";
      type = "gem";
    };
    version = "0.18.0";
  };
  coderay = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
      type = "gem";
    };
    version = "1.1.3";
  };
  coffee-rails = {
    dependencies = ["coffee-script" "railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "170sp4y82bf6nsczkkkzypzv368sgjg6lfrkib4hfjgxa6xa3ajx";
      type = "gem";
    };
    version = "5.0.0";
  };
  coffee-script = {
    dependencies = ["coffee-script-source" "execjs"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0rc7scyk7mnpfxqv5yy4y5q1hx3i7q3ahplcp4bq2g5r24g2izl2";
      type = "gem";
    };
    version = "2.4.1";
  };
  coffee-script-source = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1907v9q1zcqmmyqzhzych5l7qifgls2rlbnbhy5vzyr7i7yicaz1";
      type = "gem";
    };
    version = "1.12.2";
  };
  colorize = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "133rqj85n400qk6g3dhf2bmfws34mak1wqihvh3bgy9jhajw580b";
      type = "gem";
    };
    version = "0.8.1";
  };
  concurrent-ruby = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0nwad3211p7yv9sda31jmbyw6sdafzmdi2i2niaz6f0wk5nq9h0f";
      type = "gem";
    };
    version = "1.1.9";
  };
  connection_pool = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0ffdxhgirgc86qb42yvmfj6v1v0x4lvi0pxn9zhghkff44wzra0k";
      type = "gem";
    };
    version = "2.2.5";
  };
  constant_resolver = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1skbj1q3ck8p5nsavisk0sszydgrbq319ny1b9pm336bfwag8v0a";
      type = "gem";
    };
    version = "0.1.5";
  };
  contact_management = {
    groups = ["default"];
    platforms = [];
    source = {
      path = components/contact_management;
      type = "path";
    };
    version = "0.0.1";
  };
  converting = {
    groups = ["default"];
    platforms = [];
    source = {
      path = components/converting;
      type = "path";
    };
    version = "0.0.1";
  };
  countries = {
    dependencies = ["i18n_data" "sixarm_ruby_unaccent" "unicode_utils"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "00kzq7h7d58b6j4b37k7s5nqkbcva5f2n4j28myn0jfl4x2iacwj";
      type = "gem";
    };
    version = "3.1.0";
  };
  country_select = {
    dependencies = ["countries" "sort_alphabetical"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0cdld0yni1idnb1340wkxw1i9xlim2vci476p095r3ii44bv4h83";
      type = "gem";
    };
    version = "5.1.0";
  };
  crack = {
    dependencies = ["rexml"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1cr1kfpw3vkhysvkk3wg7c54m75kd68mbm9rs5azdjdq57xid13r";
      type = "gem";
    };
    version = "0.4.5";
  };
  crass = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      type = "gem";
    };
    version = "1.0.6";
  };
  crystalball = {
    dependencies = ["git"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1why2py76hv2m7i3a1im3zi5zcjcvz2l1nvshzndlwah58vrywkf";
      type = "gem";
    };
    version = "0.7.0";
  };
  csvlint = {
    dependencies = ["activesupport" "addressable" "colorize" "mime-types" "open_uri_redirections"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "749c0013694b78fc58ee4e8dae9a53c01d368ad0";
      sha256 = "1f1nywk4v4wnh17y0r9nfvday7r1s5nd23zvg3ciq6n8z74zxgxw";
      type = "git";
      url = "https://github.com/ResultadosDigitais/csvlint.rb";
    };
    version = "0.1.0";
  };
  cucumber = {
    dependencies = ["builder" "cucumber-core" "cucumber-create-meta" "cucumber-cucumber-expressions" "cucumber-gherkin" "cucumber-html-formatter" "cucumber-messages" "cucumber-wire" "diff-lcs" "multi_test" "sys-uname"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0y1ndhscrbcrzipzvsh63qzs8zjvx4hx30zavwki5i6d79s0acf0";
      type = "gem";
    };
    version = "5.3.0";
  };
  cucumber-core = {
    dependencies = ["cucumber-gherkin" "cucumber-messages" "cucumber-tag-expressions"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "082ma9ll7ds3nlmsv6y6q5971gyk15ysdwaxh0sp9raiihd53hi4";
      type = "gem";
    };
    version = "8.0.1";
  };
  cucumber-create-meta = {
    dependencies = ["cucumber-messages" "sys-uname"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1wdhdyz8h97m3c4wwdlnjk3lpgxv539jgagf5msrkrnyz6kw3184";
      type = "gem";
    };
    version = "2.0.4";
  };
  cucumber-cucumber-expressions = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1gby140laldy0wzbj48kpjj6k6b3i6vgb5aphbpg70fmw81gm431";
      type = "gem";
    };
    version = "10.3.0";
  };
  cucumber-gherkin = {
    dependencies = ["cucumber-messages"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0m75ymj00yddyfqr5a5178x5sv7rhh725n93n31dla36q5vyr9ll";
      type = "gem";
    };
    version = "15.0.2";
  };
  cucumber-html-formatter = {
    dependencies = ["cucumber-messages"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0szmzmpxqsq2q996zljmnfw0sai53mn7jgss9wrs37fw0ykmdlyx";
      type = "gem";
    };
    version = "9.0.0";
  };
  cucumber-messages = {
    dependencies = ["protobuf-cucumber"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "02zysv412sb76139xczfvgl3frvizv2j166bp2f5825mprsh87wm";
      type = "gem";
    };
    version = "13.2.1";
  };
  cucumber-rails = {
    dependencies = ["capybara" "cucumber" "mime-types" "nokogiri" "railties"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0hjqffkj7vpds7mz5agyp1ca1ls8lznwp9dk2m892kkygzd0isy7";
      type = "gem";
    };
    version = "2.3.0";
  };
  cucumber-tag-expressions = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1f0s8xsxv9ysd535lzmgs4m5jfwb9i738wxycswb1f349scs2jdb";
      type = "gem";
    };
    version = "2.0.4";
  };
  cucumber-wire = {
    dependencies = ["cucumber-core" "cucumber-cucumber-expressions" "cucumber-messages"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "109nfjwq2bv32pqkis775nnyqc2rbfnwy0nbvcmhhsgc7x44x2a4";
      type = "gem";
    };
    version = "4.0.1";
  };
  cuprite = {
    dependencies = ["capybara" "ferrum"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1gz7min595pq4xkzm1nvn538i7plg7jwfc1pw6w8f4apfh94fv56";
      type = "gem";
    };
    version = "0.13";
  };
  dashboard_client = {
    dependencies = ["pg" "sequel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1bka4gc68mxynn1gagfpzniy0qwpd669myiv8k2giv27lvsl2xxl";
      type = "gem";
    };
    version = "0.7.1";
  };
  data-lake-producer = {
    dependencies = ["activemodel" "google-cloud-pubsub" "redis" "upperkut"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0cgzz375s9kq150jwnpds35zc2dpwn6b7ch6zdrf7jy1h4xwn9i3";
      type = "gem";
    };
    version = "2.0.3";
  };
  database_cleaner = {
    dependencies = ["database_cleaner-active_record"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1x4r22rnpwnm9yln88vhzqj4cl3sbd26c4j50g9k6wp7y01rln4w";
      type = "gem";
    };
    version = "2.0.1";
  };
  database_cleaner-active_record = {
    dependencies = ["activerecord" "database_cleaner-core"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1yxxa38m06cl7qrpdcjxxcga4pmb50f7zrnd8khr75sba0ivsnym";
      type = "gem";
    };
    version = "2.0.1";
  };
  database_cleaner-core = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0v44bn386ipjjh4m2kl53dal8g4d41xajn2jggnmjbhn6965fil6";
      type = "gem";
    };
    version = "2.0.1";
  };
  ddtrace = {
    dependencies = ["ffi" "msgpack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1pjch5dfq87mj21gw4by72lv5hb47pgvq3h2h4jakwy2lnpg9xf5";
      type = "gem";
    };
    version = "0.49.0";
  };
  debug_inspector = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "01l678ng12rby6660pmwagmyg8nccvjfgs3487xna7ay378a59ga";
      type = "gem";
    };
    version = "1.1.0";
  };
  declarative = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1yczgnqrbls7shrg63y88g7wand2yp9h6sf56c9bdcksn5nds8c0";
      type = "gem";
    };
    version = "0.0.20";
  };
  diff-lcs = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0m925b8xc6kbpnif9dldna24q1szg4mk0fvszrki837pfn46afmz";
      type = "gem";
    };
    version = "1.4.4";
  };
  digest-crc = {
    dependencies = ["rake"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "118d5p02kdw6a5pi8af12dxma7q3b77zz5q5xjjf5kgp8qh1930a";
      type = "gem";
    };
    version = "0.6.3";
  };
  docile = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1lxqxgq71rqwj1lpl9q1mbhhhhhhdkkj7my341f2889pwayk85sz";
      type = "gem";
    };
    version = "1.4.0";
  };
  dogstatsd-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "091ycc6yx85wnp9nirzrzbgsiv798b7x0ykp0yvqvsql5ivyz619";
      type = "gem";
    };
    version = "5.0.1";
  };
  domain_name = {
    dependencies = ["unf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0lcqjsmixjp52bnlgzh4lg9ppsk52x9hpwdjd53k8jnbah2602h0";
      type = "gem";
    };
    version = "0.5.20190701";
  };
  domainatrix = {
    dependencies = ["addressable"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "07jk95gwrkw94vkmilwpj96ayrv92j3cdxsbxlf12bm0x315px45";
      type = "gem";
    };
    version = "0.0.11";
  };
  draper = {
    dependencies = ["actionpack" "activemodel" "activemodel-serializers-xml" "activesupport" "request_store"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0dayvbidlgkpja8hjp0yb5dskh8w2ni09kzbkkmicp16vn0ac7wn";
      type = "gem";
    };
    version = "3.1.0";
  };
  dynamics_crm = {
    dependencies = ["builder" "marcel"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "c4c885d67246cd8d8f4ec3b550655b9c7acc7b98";
      sha256 = "0v7s19qg4d82j8isdzprh5hv4ajkm4hvipgjz46xgm687ihl13af";
      type = "git";
      url = "https://github.com/TinderBox/dynamics_crm.git";
    };
    version = "0.9.1.1";
  };
  ecma-re-validator = {
    dependencies = ["regexp_parser"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1mz0nsl2093jd94nygw8qs13rwfwl1ax76xz3ypinr5hqbc5pab6";
      type = "gem";
    };
    version = "0.3.0";
  };
  elasticsearch = {
    dependencies = ["elasticsearch-api" "elasticsearch-transport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1q8rfv8izrchx1zjw3s0yzibh02vahh8j12bj03a6aq92vac7vqm";
      type = "gem";
    };
    version = "5.0.5";
  };
  elasticsearch-api = {
    dependencies = ["multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0f31f3l6x96w6rg73jqbfj6vh24468cmb94c2g93yfwjy044ga9l";
      type = "gem";
    };
    version = "5.0.5";
  };
  elasticsearch-model = {
    dependencies = ["activesupport" "elasticsearch" "hashie"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "03ahyqzm7khdmr2hvvhghng68b11aqsc4sja1lbjhj9y2zvglwxb";
      type = "gem";
    };
    version = "5.1.0";
  };
  elasticsearch-rails = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "14mslbv0220l0inv4d3nlkbp33xqjkz6qmqpj719hd5r518ilf2d";
      type = "gem";
    };
    version = "5.1.0";
  };
  elasticsearch-transport = {
    dependencies = ["faraday" "multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0dfa3y3dnls242bavyyjh97rpf62v62a8l0av3hzbfzfkmda5jiq";
      type = "gem";
    };
    version = "5.0.5";
  };
  email_services = {
    groups = ["default"];
    platforms = [];
    source = {
      path = components/email_services;
      type = "path";
    };
    version = "0.0.1";
  };
  equalizer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1kjmx3fygx8njxfrwcmn7clfhjhb6bvv3scy2lyyi0wqyi3brra4";
      type = "gem";
    };
    version = "0.0.11";
  };
  erubi = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "09l8lz3j00m898li0yfsnb6ihc63rdvhw3k5xczna5zrjk104f2l";
      type = "gem";
    };
    version = "1.10.0";
  };
  erubis = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3";
      type = "gem";
    };
    version = "2.7.0";
  };
  ethon = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1bby4hbq96vnzcdbbybcbddin8dxdnj1ns758kcr4akykningqhh";
      type = "gem";
    };
    version = "0.14.0";
  };
  excon = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1159ysmisd52wyq6x5qdyvip5bj0sykmi546fflyjpkjnpll25ka";
      type = "gem";
    };
    version = "0.82.0";
  };
  execjs = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "121h6af4i6wr3wxvv84y53jcyw2sk71j5wsncm6wq6yqrwcrk4vd";
      type = "gem";
    };
    version = "2.8.1";
  };
  factory_bot = {
    dependencies = ["activesupport"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "04vxmjr200akcil9fqxc9ghbb9q0lyrh2q03xxncycd5vln910fi";
      type = "gem";
    };
    version = "6.2.0";
  };
  factory_bot_rails = {
    dependencies = ["factory_bot" "railties"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "18fhcihkc074gk62iwqgbdgc3ymim4fm0b4p3ipffy5hcsb9d2r7";
      type = "gem";
    };
    version = "6.2.0";
  };
  faker = {
    dependencies = ["i18n"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1hwir9b9zy0asy0vap7zfqv75lbws4a1pmh74lhqd2rndv32vfc5";
      type = "gem";
    };
    version = "2.18.0";
  };
  faraday = {
    dependencies = ["multipart-post"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "172dirvq89zk57rv42n00rhbc2qwv1w20w4zjm6zvfqz4rdpnrqi";
      type = "gem";
    };
    version = "0.17.4";
  };
  faraday_middleware = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1x7jgvpzl1nm7hqcnc8carq6yj1lijq74jv8pph4sb3bcpfpvcsc";
      type = "gem";
    };
    version = "0.14.0";
  };
  feature_flagger = {
    dependencies = ["redis" "redis-namespace"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0jrrx4mgrw133y7k55q6zyc917hfv8asjn1djrncb88m6qahanzz";
      type = "gem";
    };
    version = "1.2.1";
  };
  ferrum = {
    dependencies = ["addressable" "cliver" "concurrent-ruby" "websocket-driver"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "17c2bryyzpdx3mj6rig4aym3wy24g2212zm0jz2gisbymhv9adbl";
      type = "gem";
    };
    version = "0.11";
  };
  ffi = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "15nn2v70rql15vb0pm9cg0f3xsaslwjkv6xgz0k5jh48idmfw9fi";
      type = "gem";
    };
    version = "1.15.1";
  };
  ffi-compiler = {
    dependencies = ["ffi" "rake"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0c2caqm9wqnbidcb8dj4wd3s902z15qmgxplwyfyqbwa0ydki7q1";
      type = "gem";
    };
    version = "1.0.1";
  };
  filelock = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "085vrb6wf243iqqnrrccwhjd4chphfdsybkvjbapa2ipfj1ja1sj";
      type = "gem";
    };
    version = "1.1.1";
  };
  find_a_port = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1sswgpvn38yav4i21adrr7yy8c8299d7rj065gd3iwg6nn26lpb0";
      type = "gem";
    };
    version = "1.0.1";
  };
  fivemat = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0pzlycasvwmg4bbx7plllpqnhd9zlmmff8l2w3yii86nrm2nvf9n";
      type = "gem";
    };
    version = "1.3.7";
  };
  fog-aws = {
    dependencies = ["fog-core" "fog-json" "fog-xml" "ipaddress"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "09npjbn3m4370wh2124pg4l8zpzfjry9h8gwazj6d7xwcvh5a26w";
      type = "gem";
    };
    version = "3.10.0";
  };
  fog-core = {
    dependencies = ["builder" "excon" "formatador" "mime-types"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0l5zk5pzyrydavyw2ai6yz97alg4qvd93mb19m6460vzrj6x00qg";
      type = "gem";
    };
    version = "2.2.4";
  };
  fog-json = {
    dependencies = ["fog-core" "multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1zj8llzc119zafbmfa4ai3z5s7c4vp9akfs0f9l2piyvcarmlkyx";
      type = "gem";
    };
    version = "1.2.0";
  };
  fog-xml = {
    dependencies = ["fog-core" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "043lwdw2wsi6d55ifk0w3izi5l1d1h0alwyr3fixic7b94kc812n";
      type = "gem";
    };
    version = "0.1.3";
  };
  formatador = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1gc26phrwlmlqrmz4bagq1wd5b7g64avpx0ghxr9xdxcvmlii0l0";
      type = "gem";
    };
    version = "0.2.5";
  };
  gapic-common = {
    dependencies = ["google-protobuf" "googleapis-common-protos" "googleapis-common-protos-types" "googleauth" "grpc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0l4pj0vjxvb3h0g1avy8x58iq3p9l022qqhz8fcbycpbbxi0n9kx";
      type = "gem";
    };
    version = "0.3.4";
  };
  gems = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1w26k4db8yj6x1gpxvh1rma4p36hz61xkk7kjf0z61nrajyp8g9l";
      type = "gem";
    };
    version = "1.2.0";
  };
  git = {
    dependencies = ["rchardet"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0vdcv93s33d9914a9nxrn2y2qv15xk7jx94007cmalp159l08cnl";
      type = "gem";
    };
    version = "1.8.1";
  };
  gli = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1jg2pdq22l13hgkvhnzsgcs868rjchsh5cdc48ijdv5byb825fm3";
      type = "gem";
    };
    version = "2.20.0";
  };
  globalid = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1zkxndvck72bfw235bd9nl2ii0lvs5z88q14706cmn702ww2mxv1";
      type = "gem";
    };
    version = "0.4.2";
  };
  globalize = {
    dependencies = ["activemodel" "activerecord" "request_store"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0alc4q0lawhpjqpqy7a3lrdv8jglwah3c542xlly04m8vj2fyr0g";
      type = "gem";
    };
    version = "6.0.0";
  };
  gooddata = {
    dependencies = ["activesupport" "aws-sdk-s3" "backports" "docile" "erubis" "gli" "highline" "json_pure" "multi_json" "parseconfig" "pmap" "remote_syslog_logger" "rest-client" "restforce" "rubyzip" "salesforce_bulk_query" "terminal-table" "thread_safe" "tty-spinner"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "dca92770bdc46cc3c87f533fcaffea3b9e6ea703";
      sha256 = "05nkgr2frm0ybzm0q8bpbx4m6hl3pq3972jby02d074p0dfn7qgv";
      type = "git";
      url = "https://github.com/gooddata/gooddata-ruby.git";
    };
    version = "2.1.15";
  };
  gooder_data = {
    dependencies = ["gpgme" "httparty"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0vbxlv2fah9j8ggsmdydib8jrdvnfcvkcg4lj5dhavgxlxjflank";
      type = "gem";
    };
    version = "0.0.35";
  };
  google-api-client = {
    dependencies = ["google-apis-core" "google-apis-generator"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1zypv7qz37ql5fqnlmk39krbazzshjzsw44syg7p0ap03zr6w021";
      type = "gem";
    };
    version = "0.53.0";
  };
  google-apis-core = {
    dependencies = ["addressable" "googleauth" "httpclient" "mini_mime" "representable" "retriable" "rexml" "signet" "webrick"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1jx4jiyfjxd8pxlpi94f07cb5yvljb5rv7i8xzjq2xrrlvdf212a";
      type = "gem";
    };
    version = "0.3.0";
  };
  google-apis-discovery_v1 = {
    dependencies = ["google-apis-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "07azdrj9c9pypi4c43d1dr18vcjz0q4q77i4zkxznw3i5csiid2h";
      type = "gem";
    };
    version = "0.4.0";
  };
  google-apis-generator = {
    dependencies = ["activesupport" "gems" "google-apis-core" "google-apis-discovery_v1" "thor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0vjgqxcjxnvmqxc53zgrslig1magqx8mjacz3syzzjk5wa2861zp";
      type = "gem";
    };
    version = "0.3.0";
  };
  google-cloud-core = {
    dependencies = ["google-cloud-env" "google-cloud-errors"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0amp8vd16pzbdrfbp7k0k38rqxpwd88bkyp35l3x719hbb6l85za";
      type = "gem";
    };
    version = "1.6.0";
  };
  google-cloud-env = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0ajc3w4wqg46ywcbmb5fz1q6gfm6g7874s9h31i1r038kz2bzfag";
      type = "gem";
    };
    version = "1.5.0";
  };
  google-cloud-errors = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0q3h996b6vl2ryfbm9jwczjcbnwhkpqs6hingxp22rhzk7qxi9z0";
      type = "gem";
    };
    version = "1.1.0";
  };
  google-cloud-pubsub = {
    dependencies = ["concurrent-ruby" "google-cloud-core" "google-cloud-pubsub-v1"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0khlgagga4swgd7ag59k35rilp2kp64kq7izfd75kxhz5z0236il";
      type = "gem";
    };
    version = "2.3.0";
  };
  google-cloud-pubsub-v1 = {
    dependencies = ["gapic-common" "google-cloud-errors" "grpc-google-iam-v1"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "11dm7vmqx8i9wagbandqdbrfin9qbra9r584lrmqjqqna9znqry5";
      type = "gem";
    };
    version = "0.4.0";
  };
  google-cloud-storage = {
    dependencies = ["addressable" "digest-crc" "google-api-client" "google-cloud-core" "googleauth" "mini_mime"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0dy5f00jsnd6id7bkc03pl2d6c78rl3lkysdn0f90padys5id1k5";
      type = "gem";
    };
    version = "1.29.2";
  };
  google-cloud-vision = {
    dependencies = ["google-gax"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1mgwi7ssgk89262igdmb57n7z7dr9qby4cyh13hldcr2lkk0y8dy";
      type = "gem";
    };
    version = "0.36.0";
  };
  google-gax = {
    dependencies = ["google-protobuf" "googleapis-common-protos" "googleauth" "grpc" "rly"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0f1jnanwi1kxkhna8v39fgrhkrp3582mv2vq3cizzks100dmk55v";
      type = "gem";
    };
    version = "1.8.1";
  };
  google-protobuf = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "040yprd0j8v74i8xlsrrd80q2fjnzynrc5q8jary1p61h18z3bqa";
      type = "gem";
    };
    version = "3.17.2";
  };
  google_url_shortener = {
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "7450fd0cd4db8a545755f458e4a0bba889294fbc";
      sha256 = "0lddp9vfgmglpvsbb3pgc7rsd4dmhs42lql3vn748a7gw40ffcjd";
      type = "git";
      url = "https://github.com/ResultadosDigitais/google_url_shortener";
    };
    version = "0.1.0";
  };
  googleapis-common-protos = {
    dependencies = ["google-protobuf" "googleapis-common-protos-types" "grpc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0p8fxzjg0knfpc9bx75s21l520iz4ips95d3210g2ycwgxp7pcs3";
      type = "gem";
    };
    version = "1.3.11";
  };
  googleapis-common-protos-types = {
    dependencies = ["google-protobuf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0074jk8fdl5rh7hfgx00n17sg493xrylkjkslx2d7cj5mk6hwn7d";
      type = "gem";
    };
    version = "1.0.6";
  };
  googleauth = {
    dependencies = ["faraday" "jwt" "memoist" "multi_json" "os" "signet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0py7488bcp1889sl2ypnhlhf03zvbmih51zva5fwb9clba374z05";
      type = "gem";
    };
    version = "0.16.2";
  };
  gpgme = {
    dependencies = ["mini_portile2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0xbgh9d8nbvsvyzqnd0mzhz0nr9hx4qn025kmz6d837lry4lc6gw";
      type = "gem";
    };
    version = "2.0.20";
  };
  graphql = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "021b5d5gk2ndkpna0ss0n8cffza55cmjag9p5051lyy3r037w5hr";
      type = "gem";
    };
    version = "1.12.12";
  };
  grpc = {
    dependencies = ["google-protobuf" "googleapis-common-protos-types"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "16qxl287kkf34h71djlf9x3wxmd5ylcm83y2zhnrv81gbrhn8k12";
      type = "gem";
    };
    version = "1.38.0";
  };
  grpc-google-iam-v1 = {
    dependencies = ["google-protobuf" "googleapis-common-protos" "grpc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1jczdvjv6iqwmzr9xm1k230hp3aism2a53ash0af5q7bkpcnslrs";
      type = "gem";
    };
    version = "0.6.11";
  };
  gyoku = {
    dependencies = ["builder"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1wn0sl14396g5lyvp8sjmcb1hw9rbyi89gxng91r7w4df4jwiidh";
      type = "gem";
    };
    version = "1.3.1";
  };
  hana = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "03cvrv2wl25j9n4n509hjvqnmwa60k92j741b64a1zjisr1dn9al";
      type = "gem";
    };
    version = "1.3.7";
  };
  hashdiff = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1nynpl0xbj0nphqx1qlmyggq58ms1phf5i03hk64wcc0a17x1m1c";
      type = "gem";
    };
    version = "1.0.1";
  };
  hashie = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "13bdzfp25c8k51ayzxqkbzag3wj5gc1jd8h7d985nsq6pn57g5xh";
      type = "gem";
    };
    version = "3.6.0";
  };
  highline = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1gfn969iy4hsngmsw7qlvxq3l82zmrl07s7p2la2p6j77cxcpm46";
      type = "gem";
    };
    version = "2.0.0.pre.develop.14";
  };
  html_tokenizer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0dq6685sdzdn53mkzags6mvx3l0afcx6xma664zij6y3dxj2a7p8";
      type = "gem";
    };
    version = "0.0.7";
  };
  htmlcompressor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "17hzzg7alnmalb1xgv1bgw3aj5wczsijhq6c945kymkbsj7cyc26";
      type = "gem";
    };
    version = "0.4.0";
  };
  htmlentities = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1nkklqsn8ir8wizzlakncfv42i32wc0w9hxp00hvdlgjr7376nhj";
      type = "gem";
    };
    version = "4.3.4";
  };
  http = {
    dependencies = ["addressable" "http-cookie" "http-form_data" "http-parser"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0z8vmvnkrllkpzsxi94284di9r63g9v561a16an35izwak8g245y";
      type = "gem";
    };
    version = "4.4.1";
  };
  http-cookie = {
    dependencies = ["domain_name"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "004cgs4xg5n6byjs7qld0xhsjq3n6ydfh897myr2mibvh6fjc49g";
      type = "gem";
    };
    version = "1.0.3";
  };
  http-form_data = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1wx591jdhy84901pklh1n9sgh74gnvq1qyqxwchni1yrc49ynknc";
      type = "gem";
    };
    version = "2.3.0";
  };
  http-parser = {
    dependencies = ["ffi-compiler"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "18qqvckvqjffh88hfib6c8pl9qwk9gp89w89hl3f2s1x8hgyqka1";
      type = "gem";
    };
    version = "1.2.3";
  };
  "http_parser.rb" = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "15nidriy0v5yqfjsgsra51wmknxci2n2grliz78sf9pga3n0l7gi";
      type = "gem";
    };
    version = "0.6.0";
  };
  httparty = {
    dependencies = ["mime-types" "multi_xml"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "17gpnbf2a7xkvsy20jig3ljvx8hl5520rqm9pffj2jrliq1yi3w7";
      type = "gem";
    };
    version = "0.18.1";
  };
  httpclient = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "19mxmvghp7ki3klsxwrlwr431li7hm1lczhhj8z4qihl2acy8l99";
      type = "gem";
    };
    version = "2.8.3";
  };
  httpi = {
    dependencies = ["rack" "socksify"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "05mk35q1761p6iq401rdgm8gsjfd23ldp0dlw1apxz8jrimfxcjg";
      type = "gem";
    };
    version = "2.4.5";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0g2fnag935zn2ggm5cn6k4s4xvv53v2givj1j90szmvavlpya96a";
      type = "gem";
    };
    version = "1.8.10";
  };
  i18n-js = {
    dependencies = ["i18n"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0qq2cnnsfj5zsm2lhz78ifwrcvszwd0al4pvf5cjgdfgj7i37f0c";
      type = "gem";
    };
    version = "3.0.11";
  };
  i18n-spec = {
    dependencies = ["iso"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1l2nk6dkk5c2smiamd8zc39gm8z5p555gs2ki4p2ln08xpfhqy1q";
      type = "gem";
    };
    version = "0.6.0";
  };
  i18n_data = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1icayqqp27215rp3si5pm76hbd19apcm4ya48048qc5cjzadgsm8";
      type = "gem";
    };
    version = "0.11.0";
  };
  iconv = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "00fppiz9ypy7xpc08xdk6glq842rbc69c7a1p0kmv195271i4yqv";
      type = "gem";
    };
    version = "1.0.8";
  };
  image_processing = {
    dependencies = ["mini_magick" "ruby-vips"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1778lv4lpwk9ffm0zy7w59gzchq19f22a5gfrdk6qa7l9vx89h11";
      type = "gem";
    };
    version = "1.12.1";
  };
  ipaddress = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1x86s0s11w202j6ka40jbmywkrx8fhq8xiy8mwvnkhllj57hqr45";
      type = "gem";
    };
    version = "0.8.3";
  };
  iso = {
    dependencies = ["i18n"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0zyhffq05w5yv8sgmidszx45l2fhm6g41wl14ddr0d5rbm2x5rk0";
      type = "gem";
    };
    version = "0.4.0";
  };
  jbuilder = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1vz0vp5lbp1bz2samyn8nk49vyh6zhvcqz35faq4i3kgsd4xlnhp";
      type = "gem";
    };
    version = "2.11.2";
  };
  jmespath = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1d4wac0dcd1jf6kc57891glih9w57552zgqswgy74d1xhgnk0ngf";
      type = "gem";
    };
    version = "1.4.0";
  };
  jquery-fileupload-rails = {
    dependencies = ["actionpack" "railties" "sass"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1402wycbb790b0355xga36dzzqxx5k89qi28jl9qbfk0sy41kpx8";
      type = "gem";
    };
    version = "0.4.7";
  };
  jquery-rails = {
    dependencies = ["rails-dom-testing" "railties" "thor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0dkhm8lan1vnyl3ll0ks2q06576pdils8a1dr354vfc1y5dqw15i";
      type = "gem";
    };
    version = "4.4.0";
  };
  jquery-ui-rails = {
    dependencies = ["railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1mbwwbbwzp836l7mc21amnaqmf5wbrw5hzls48hscrcgh0vig812";
      type = "gem";
    };
    version = "6.0.1";
  };
  json = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0qmj7fypgb9vag723w1a49qihxrcf5shzars106ynw2zk352gbv5";
      type = "gem";
    };
    version = "1.8.6";
  };
  json_pure = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1vllrpm2hpsy5w1r7000mna2mhd7yfrmd8hi713lk0n9mv27bmam";
      type = "gem";
    };
    version = "1.8.6";
  };
  json_schemer = {
    dependencies = ["ecma-re-validator" "hana" "regexp_parser" "uri_template"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1rkb7gz819g82n3xshb5g8kgv1nvgwg1lm2fk7715pggzcgc4qik";
      type = "gem";
    };
    version = "0.2.18";
  };
  jsonapi-renderer = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0ys4drd0k9rw5ixf8n8fx8v0pjh792w4myh0cpdspd317l1lpi5m";
      type = "gem";
    };
    version = "0.2.2";
  };
  jsonpath = {
    dependencies = ["multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "12hjsr0plnx6v0bh1rhhimfi7z3rqm19xb47ybdkc1h9yhynnmdq";
      type = "gem";
    };
    version = "1.1.0";
  };
  jwt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "124zz1142bi2if7hl5pcrcamwchv4icyr5kaal9m2q6wqbdl6aw4";
      type = "gem";
    };
    version = "1.5.6";
  };
  koala = {
    dependencies = ["addressable" "faraday" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1k7nlif8nwgb6bfkclry41xklaf4rqf18ycgq63sgkgj6zdpda4w";
      type = "gem";
    };
    version = "3.0.0";
  };
  launchy = {
    dependencies = ["addressable"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1xdyvr5j0gjj7b10kgvh8ylxnwk3wx19my42wqn9h82r4p246hlm";
      type = "gem";
    };
    version = "2.5.0";
  };
  lead_tracker_client = {
    dependencies = ["microservice-toolkit"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "01ipd48d60303vmv3g4mpsrg9b9v2gjfi8fid76kv2h8izjzwx1c";
      type = "gem";
    };
    version = "0.3.0";
  };
  linkedin-api = {
    dependencies = ["faraday" "faraday_middleware" "hashie"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "039l2n7n6rfsd5q9mvfpk7awpn718hb5w2xdpvpmiiy7n6dknbmg";
      type = "gem";
    };
    version = "0.5.4";
  };
  lograge = {
    dependencies = ["actionpack" "activesupport" "railties" "request_store"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1vrjm4yqn5l6q5gsl72fmk95fl6j9z1a05gzbrwmsm3gp1a1bgac";
      type = "gem";
    };
    version = "0.11.2";
  };
  loofah = {
    dependencies = ["crass" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1w9mbii8515p28xd4k72f3ab2g6xiyq15497ys5r8jn6m355lgi7";
      type = "gem";
    };
    version = "2.9.1";
  };
  mail = {
    dependencies = ["mini_mime"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "00wwz6ys0502dpk8xprwcqfwyf3hmnx6lgxaiq6vj43mkx43sapc";
      type = "gem";
    };
    version = "2.7.1";
  };
  mailcannon = {
    dependencies = ["mongoid" "redis" "redis-namespace" "sendgrid-ruby" "sendgrid_webapi" "sidekiq"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0qhbbyn95mfd325f93j3pav5r4cbqx01q18pg9sgi9a60kgbpm0c";
      type = "gem";
    };
    version = "0.9.1";
  };
  marcel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0bp001p687nsa4a8sp3q1iv8pfhs24w7s3avychjp64sdkg6jxq3";
      type = "gem";
    };
    version = "1.0.1";
  };
  memoist = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0i9wpzix3sjhf6d9zw60dm4371iq8kyz7ckh2qapan2vyaim6b55";
      type = "gem";
    };
    version = "0.16.2";
  };
  memoizable = {
    dependencies = ["thread_safe"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0v42bvghsvfpzybfazl14qhkrjvx0xlmxz0wwqc960ga1wld5x5c";
      type = "gem";
    };
    version = "0.4.2";
  };
  memory_profiler = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "04ivhv1bilwqm33jv28gar2vwzsichb5nipaq395d3axabv8qmfy";
      type = "gem";
    };
    version = "0.9.14";
  };
  method_source = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1pnyh44qycnf9mzi1j6fywd5fkskv3x7nmsqrrws0rjn5dd4ayfp";
      type = "gem";
    };
    version = "1.0.0";
  };
  metrics-exporter-client = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0pal5c16cs5mksa8zmwymb63qmcy7k2ax3riw25awlwzrzw57qbn";
      type = "gem";
    };
    version = "2.0.0";
  };
  microservice-toolkit = {
    dependencies = ["actionpack" "activesupport" "anyway_config" "api-auth" "faraday" "json_schemer" "jwt" "metrics-exporter-client" "opentelemetry-api" "opentelemetry-exporter-jaeger" "opentelemetry-instrumentation-rails" "opentelemetry-instrumentation-redis" "opentelemetry-instrumentation-sidekiq" "opentelemetry-resource_detectors" "opentelemetry-sdk"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0mr4ysm0shz9d32cmhck968ahdg0bzaaa2mrnmbd37dy06wq46k0";
      type = "gem";
    };
    version = "0.20.2";
  };
  middleware = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0703nkf2v371wqr41c04x5qid7ww45cxqv3hnlg07if3b3xrm9xl";
      type = "gem";
    };
    version = "0.1.0";
  };
  mime-types = {
    dependencies = ["mime-types-data"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1zj12l9qk62anvk9bjvandpa6vy4xslil15wl6wlivyf51z773vh";
      type = "gem";
    };
    version = "3.3.1";
  };
  mime-types-data = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1phcq7z0zpipwd7y4fbqmlaqghv07fjjgrx99mwq3z3n0yvy7fmi";
      type = "gem";
    };
    version = "3.2021.0225";
  };
  mini_magick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1aj604x11d9pksbljh0l38f70b558rhdgji1s9i763hiagvvx2hs";
      type = "gem";
    };
    version = "4.11.0";
  };
  mini_mime = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1np6srnyagghhh2w4nyv09sz47v0i6ri3q6blicj94vgxqp12c94";
      type = "gem";
    };
    version = "1.0.3";
  };
  mini_portile2 = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "15zplpfw3knqifj9bpf604rb3wc1vhq6363pd6lvhayng8wql5vy";
      type = "gem";
    };
    version = "2.4.0";
  };
  minitest = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "19z7wkhg59y8abginfrm2wzplz7py3va8fyngiigngqvsws6cwgl";
      type = "gem";
    };
    version = "5.14.4";
  };
  mongo = {
    dependencies = ["bson"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1w0f3ka716z69s9ybjgv27cvpzxgpdixplrj1ci4nza5c9cywvf7";
      type = "gem";
    };
    version = "2.14.0";
  };
  mongoid = {
    dependencies = ["activemodel" "mongo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "18djx5j272n5pxybwr2kcy4xx2y4rf8q822r57ylx426jnh0603w";
      type = "gem";
    };
    version = "7.0.13";
  };
  mousetrap-rails = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "00n13r5pwrk4vq018128vcfh021dw0fa2bk4pzsv0fslfm8ayp2m";
      type = "gem";
    };
    version = "1.4.6";
  };
  msgpack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "06iajjyhx0rvpn4yr3h1hc4w4w3k59bdmfhxnjzzh76wsrdxxrc6";
      type = "gem";
    };
    version = "1.4.2";
  };
  multi_json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0pb1g1y3dsiahavspyzkdy39j4q377009f6ix0bh1ag4nqw43l0z";
      type = "gem";
    };
    version = "1.15.0";
  };
  multi_test = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1sx356q81plr67hg16jfwz9hcqvnk03bd9n75pmdw8pfxjfy1yxd";
      type = "gem";
    };
    version = "0.1.2";
  };
  multi_xml = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0lmd4f401mvravi1i1yq7b2qjjli0yq7dfc4p1nj5nwajp7r6hyj";
      type = "gem";
    };
    version = "0.6.0";
  };
  multipart-post = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1zgw9zlwh2a6i1yvhhc4a84ry1hv824d6g2iw2chs3k5aylpmpfj";
      type = "gem";
    };
    version = "2.1.1";
  };
  multiverse_bi = {
    dependencies = ["gooddata" "gpgme" "redis-activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0243ypfvmvfa0nm6kfhcz90sswiwn7qj91v0ia431ylj9d24p34x";
      type = "gem";
    };
    version = "1.0.16";
  };
  mustermann = {
    dependencies = ["ruby2_keywords"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0ccm54qgshr1lq3pr1dfh7gphkilc19dp63rw6fcx7460pjwy88a";
      type = "gem";
    };
    version = "1.1.1";
  };
  mutation-api-client = {
    dependencies = ["google-protobuf" "googleapis-common-protos" "platform-model"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1rkhwnxwwxcpfymnns3p5pd5gff8kda5a60wzq4w01zag3zlz42m";
      type = "gem";
    };
    version = "1.21.0";
  };
  naught = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1wwjx35zgbc0nplp8a866iafk4zsrbhwwz4pav5gydr2wm26nksg";
      type = "gem";
    };
    version = "1.1.0";
  };
  neek-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0lc36107s75w9czgqin9vbviigfk6vn1rlhv84n828izgs07921l";
      type = "gem";
    };
    version = "0.2.1";
  };
  nested_form = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0f053j4zfagxyym28msxj56hrpvmyv4lzxy2c5c270f7xbbnii5i";
      type = "gem";
    };
    version = "0.3.2";
  };
  netrc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  newrelic_rpm = {
    groups = ["production" "staging"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1whi90sbl5yhy0x779mffx16fv5kmzav2bs9i9l4ybckrgaxigcq";
      type = "gem";
    };
    version = "7.1.0";
  };
  nio4r = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "00fwz0qq7agd2xkdz02i8li236qvwhma3p0jdn5bdvc21b7ydzd5";
      type = "gem";
    };
    version = "2.5.7";
  };
  nokogiri = {
    dependencies = ["mini_portile2"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0xmf60nj5kg9vaj5bysy308687sgmkasgx06vbbnf94p52ih7si2";
      type = "gem";
    };
    version = "1.10.10";
  };
  nori = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "066wc774a2zp4vrq3k7k8p0fhv30ymqmxma1jj7yg5735zls8agn";
      type = "gem";
    };
    version = "2.6.0";
  };
  oauth = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1zwd6v39yqfdrpg1p3d9jvzs9ljg55ana2p06m0l7qn5w0lgx1a0";
      type = "gem";
    };
    version = "0.5.6";
  };
  oauth2 = {
    dependencies = ["faraday" "jwt" "multi_json" "multi_xml" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1q6q2kgpxmygk8kmxqn54zkw8cs57a34zzz5cxpsh1bj3ag06rk3";
      type = "gem";
    };
    version = "1.4.7";
  };
  oj = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1cnadm83qwnmbpyild9whb9bgf9r7gs046ydxypclb2l756gcnva";
      type = "gem";
    };
    version = "3.11.5";
  };
  omniauth = {
    dependencies = ["hashie" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "002vi9gwamkmhf0dsj2im1d47xw2n1jfhnzl18shxf3ampkqfmyz";
      type = "gem";
    };
    version = "1.9.1";
  };
  omniauth-auth0 = {
    dependencies = ["omniauth-oauth2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "07c6qa5375z05cygqclzcf1c4fr38bslfwx9fkfjngvks41iar43";
      type = "gem";
    };
    version = "1.4.2";
  };
  omniauth-google-oauth2 = {
    dependencies = ["jwt" "omniauth" "omniauth-oauth2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0rdnjqs30z5wnahyjcqrf1vf4imllagp418rzh7sfhiwxqggy633";
      type = "gem";
    };
    version = "0.5.4";
  };
  omniauth-oauth2 = {
    dependencies = ["oauth2" "omniauth"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "10fr2b58sp7l6nfdvxpbi67374hkrvsf507cvda89jjs0jacy319";
      type = "gem";
    };
    version = "1.7.1";
  };
  omniauth-salesforce = {
    dependencies = ["omniauth" "omniauth-oauth2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0sr7xmffx6dbsrvnh6spka5ljyzf69iac754xw5r1736py41qhpj";
      type = "gem";
    };
    version = "1.0.5";
  };
  on-page-seo-test-suite = {
    dependencies = ["activesupport" "domainatrix" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0z4gddyvww92s8jlqdyb3v8gpcvhiqz73aa99kj111nws228gnjx";
      type = "gem";
    };
    version = "1.7.1";
  };
  open_uri_redirections = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0kn05dxh2mry50jwb3ssn9f3cdnzqa7r0xiyrh6zkn5i0sq2krir";
      type = "gem";
    };
    version = "0.2.1";
  };
  opentelemetry-api = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1ji27f87p381csy2r3wk2ad9gqsdpld7qrd5544694ha75i92njv";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentelemetry-common = {
    dependencies = ["opentelemetry-api"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "135fg2smk1r370gkxh8n1pm0yh044m638amf035878mnb7zinz3h";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentelemetry-exporter-jaeger = {
    dependencies = ["opentelemetry-api" "opentelemetry-common" "thrift"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0nzimbs2lqbsmhhdd7ndqrmbkndjzj9lxfkbxj8rq3yc675bh3py";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentelemetry-instrumentation-rack = {
    dependencies = ["opentelemetry-api"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1f2b91r29czw13gck1bnk9607kkz4srwr9mlhsrjzfpm9sk3yns4";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentelemetry-instrumentation-rails = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1x55mdw8g5vnfd1p5dbk1275mi4rn80nk9hv58jkmdcyjbi10qiw";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentelemetry-instrumentation-redis = {
    dependencies = ["opentelemetry-api" "opentelemetry-common"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "01jlx81qq9b6hhznjrfxvhl9qfv4wy4nm16lkphm3rf61ikzsiz8";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentelemetry-instrumentation-sidekiq = {
    dependencies = ["opentelemetry-api" "opentelemetry-common"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0a9iz3xsdrcdv4z91ky98nz5syi5c70fkjac9hay6sy61i45zss9";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentelemetry-resource_detectors = {
    dependencies = ["google-cloud-env"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0bqlm7rj1czmqd29v9m3cncg31cz1yfq7fnppfiga63iyia37pc1";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentelemetry-sdk = {
    dependencies = ["opentelemetry-api" "opentelemetry-common"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "16xq32w857qncakdb3j42d4g202nb0jn3dsgnp3kl1vv2m9mj9dk";
      type = "gem";
    };
    version = "0.16.0";
  };
  opentracing = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "11lj1d8vq0hkb5hjz8q4lm82cddrggpbb33dhqfn7rxhwsmxgdfy";
      type = "gem";
    };
    version = "0.5.0";
  };
  os = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "12fli64wz5j9868gpzv5wqsingk1jk457qyqksv9ksmq9b0zpc9x";
      type = "gem";
    };
    version = "1.1.1";
  };
  packwerk = {
    dependencies = ["activesupport" "ast" "better_html" "constant_resolver" "parser" "sorbet-runtime"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "049favvl7my5gv2z0is9ywxlgkpg7v7r9w4432nsjhbr1c1iaakh";
      type = "gem";
    };
    version = "1.1.3";
  };
  pact = {
    dependencies = ["pact-mock_service" "pact-support" "rack-test" "rspec" "term-ansicolor" "thor" "webrick"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1mpz2b8w6n09qkzmbc9v11jdx73rjlaxgbn0r12vkim366yp268b";
      type = "gem";
    };
    version = "1.56.0";
  };
  pact-mock_service = {
    dependencies = ["filelock" "find_a_port" "json" "pact-support" "rack" "rspec" "term-ansicolor" "thor" "webrick"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0sznq1k2l8xxa06mm45aphingnw0vyqlb09d3srx7i427qa49wdz";
      type = "gem";
    };
    version = "3.9.1";
  };
  pact-support = {
    dependencies = ["awesome_print" "diff-lcs" "randexp" "term-ansicolor"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0hc13k4c8p4yffq468savacshmsqx3zwvsrihbm36k8g12mxqk09";
      type = "gem";
    };
    version = "1.16.7";
  };
  pact_broker-client = {
    dependencies = ["httparty" "json" "table_print" "term-ansicolor"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1wmhaiihzbl3234wdps522k2mq0ainwi2wbrbhdb57yn5j46dhd3";
      type = "gem";
    };
    version = "1.13.0";
  };
  paddy-ruby = {
    dependencies = ["google-cloud-pubsub" "platform-model"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1678pvmfqvp6i6sdqlgbm5nznxhwsrzv07r61k6514n3g8rc6004";
      type = "gem";
    };
    version = "0.4.8";
  };
  parallel = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0055br0mibnqz0j8wvy20zry548dhkakws681bhj3ycb972awkzd";
      type = "gem";
    };
    version = "1.20.1";
  };
  paranoia = {
    dependencies = ["activerecord"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "02plzv9qygzxa3fryz6cgap64jqrzwprjsm7r467g15mhaa4fzxi";
      type = "gem";
    };
    version = "2.4.3";
  };
  parseconfig = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "09qhqrhcy7jwz4wls2l6z4dx4428csy27nbscxn72rd973k390yi";
      type = "gem";
    };
    version = "1.1.0";
  };
  parser = {
    dependencies = ["ast"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1pxsi1i5z506xfzhiyavlasf8777h55ab40phvp7pfv9npmd5pnj";
      type = "gem";
    };
    version = "3.0.1.1";
  };
  parslet = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "12nrzfwjphjlakb9pmpj70hgjwgzvnr8i1zfzddifgyd44vspl88";
      type = "gem";
    };
    version = "1.8.2";
  };
  pg = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "13mfrysrdrh8cka1d96zm0lnfs59i5x2g6ps49r2kz5p3q81xrzj";
      type = "gem";
    };
    version = "1.2.3";
  };
  pipedrive-ruby = {
    dependencies = ["httparty" "json" "multi_xml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "09jf6pb6p8g7hk3a2z6049dn1mrl9by9svcpar0mkik1ypb8a44h";
      type = "gem";
    };
    version = "0.3.6";
  };
  platform-model = {
    dependencies = ["google-protobuf" "microservice-toolkit"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "14c1jjhmi33rjky8sqff3pa2apiz6pbql4xmmj8rii3rinznm7cd";
      type = "gem";
    };
    version = "1.19.3";
  };
  platform-model-builder = {
    dependencies = ["platform-model"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0zdknn2r99m6dwyvbrfm3sm5invv1f302iy7myx5hiv22j2q86gj";
      type = "gem";
    };
    version = "0.1.3";
  };
  pmap = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0i0q2l5bqh4ma79v24h3c2kjgb5mk277kq1fqxw9j6afqyzyaf64";
      type = "gem";
    };
    version = "1.1.1";
  };
  protobuf-cucumber = {
    dependencies = ["activesupport" "middleware" "thor" "thread_safe"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1rd6naabhpfb1i5dr6fp5mqwaawsx0mqm73h5ycwkgbm1n2si872";
      type = "gem";
    };
    version = "3.10.8";
  };
  pry = {
    dependencies = ["coderay" "method_source"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0m445x8fwcjdyv2bc0glzss2nbm1ll51bq45knixapc7cl3dzdlr";
      type = "gem";
    };
    version = "0.14.1";
  };
  pry-byebug = {
    dependencies = ["byebug" "pry"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "07cv2hddswb334777pjgc9avxn0x9qhrdr191g7windvnjk3scvg";
      type = "gem";
    };
    version = "3.8.0";
  };
  psych = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "04w5746vy795pbkw16ib371izrq6abgqnpwl7jk2h5zrsk72jmg8";
      type = "gem";
    };
    version = "2.0.17";
  };
  public_suffix = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1xqcgkl7bwws1qrlnmxgh8g4g9m10vg60bhlw40fplninb3ng6d9";
      type = "gem";
    };
    version = "4.0.6";
  };
  puma = {
    dependencies = ["nio4r"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0lmaq05a257m9588a81wql3a5p039f221f0dmq57bm2qjwxydjmj";
      type = "gem";
    };
    version = "5.3.2";
  };
  rack = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0i5vs0dph9i5jn8dfc6aqd6njcafmb20rwqngrf759c9cvmyff16";
      type = "gem";
    };
    version = "2.2.3";
  };
  rack-cors = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0lcm0zw1q0c0fivdc0wldgkbr069p7p8b02if0ib5y4l0mnfaw29";
      type = "gem";
    };
    version = "0.4.1";
  };
  rack-protection = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "159a4j4kragqh0z0z8vrpilpmaisnlz3n7kgiyf16bxkwlb3qlhz";
      type = "gem";
    };
    version = "2.1.0";
  };
  rack-proxy = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0jdr2r5phr3q7d6k9cnxjwlkaps0my0n43wq9mzw3xdqhg9wa3d6";
      type = "gem";
    };
    version = "0.7.0";
  };
  rack-test = {
    dependencies = ["rack"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0rh8h376mx71ci5yklnpqqn118z3bl67nnv5k801qaqn1zs62h8m";
      type = "gem";
    };
    version = "1.1.0";
  };
  rack-timeout = {
    groups = ["production" "staging"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "16ahj3qz3xhfrwvqb4nf6cfzvliigg0idfsp5jyr8qwk676d2f30";
      type = "gem";
    };
    version = "0.6.0";
  };
  rails = {
    dependencies = ["actioncable" "actionmailbox" "actionmailer" "actionpack" "actiontext" "actionview" "activejob" "activemodel" "activerecord" "activestorage" "activesupport" "railties" "sprockets-rails"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0flnpli87b9j0zvb3c4l5addjbznbpkbmp1wzfjc1gh8qxlhcs1n";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  rails-controller-testing = {
    dependencies = ["actionpack" "actionview" "activesupport"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "151f303jcvs8s149mhx2g5mn67487x0blrf9dzl76q1nb7dlh53l";
      type = "gem";
    };
    version = "1.0.5";
  };
  rails-dom-testing = {
    dependencies = ["activesupport" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1lfq2a7kp2x64dzzi5p4cjcbiv62vxh9lyqk2f0rqq3fkzrw8h5i";
      type = "gem";
    };
    version = "2.0.3";
  };
  rails-html-sanitizer = {
    dependencies = ["loofah"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1icpqmxbppl4ynzmn6dx7wdil5hhq6fz707m9ya6d86c7ys8sd4f";
      type = "gem";
    };
    version = "1.3.0";
  };
  rails-observers = {
    dependencies = ["activemodel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0p4kmyg1p50sjr04k49lhpysl6dl55qcinmb3k9d8d79ygknmsac";
      type = "gem";
    };
    version = "0.1.5";
  };
  rails_12factor = {
    dependencies = ["rails_serve_static_assets" "rails_stdout_logging"];
    groups = ["production" "staging"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1x8gj0d3j3a789nkfrkj98icx00bannblz81z84j29k6k79qi6zf";
      type = "gem";
    };
    version = "0.0.3";
  };
  rails_serve_static_assets = {
    groups = ["production" "staging"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1sc02fp9ad4qjfb9p450fz7rvck4all468kybkpi518qmxzg0fr0";
      type = "gem";
    };
    version = "0.0.5";
  };
  rails_stdout_logging = {
    groups = ["production" "staging"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1x0l90vkrr5mjdrfgq1hz9pz4d28225n0x5mk6apa2n3kj3mhwg5";
      type = "gem";
    };
    version = "0.0.5";
  };
  railties = {
    dependencies = ["actionpack" "activesupport" "method_source" "rake" "thor"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "17r1pr8d467vh3zkciw4wmrcixj9zjrvd11nxn2z091bkzf66xq2";
      type = "gem";
    };
    version = "6.1.3.2";
  };
  rainbow = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0bb2fpjspydr6x0s8pn1pqkzmxszvkfapv0p4627mywl7ky4zkhk";
      type = "gem";
    };
    version = "3.0.0";
  };
  rake = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1iik52mf9ky4cgs38fp2m8r6skdkq1yz23vh18lk95fhbcxb6a67";
      type = "gem";
    };
    version = "13.0.3";
  };
  randexp = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1j742j7g107jgkvpsfq2b10d5xhsni5s8vxrp518d3karw7529ih";
      type = "gem";
    };
    version = "0.1.7";
  };
  rb-fsevent = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1qsx9c4jr11vr3a9s5j83avczx9qn9rjaf32gxpc2v451hvbc0is";
      type = "gem";
    };
    version = "0.11.0";
  };
  rb-inotify = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
      type = "gem";
    };
    version = "0.10.1";
  };
  rchardet = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1isj1b3ywgg2m1vdlnr41lpvpm3dbyarf1lla4dfibfmad9csfk9";
      type = "gem";
    };
    version = "1.8.0";
  };
  rdstation-sass = {
    dependencies = ["bootstrap-sass" "sass"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1s8p6v20fs0iyasl1n6zp0d0pm7402dgkp13jxffi7dh4cif6qi9";
      type = "gem";
    };
    version = "2.5.0";
  };
  redis = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "15x2sr6h094rjbvg8pkq6m3lcd5abpyx93aifvfdz3wv6x55xa48";
      type = "gem";
    };
    version = "4.2.5";
  };
  redis-activesupport = {
    dependencies = ["activesupport" "redis-store"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1l4nhf8x0wwzcx2k9p7f1v8dv0nwsmssgg1sl3h9dz0xvcq9lkib";
      type = "gem";
    };
    version = "5.2.1";
  };
  redis-namespace = {
    dependencies = ["redis"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0k65fr7f8ciq7d9nwc5ziw1d32zsxilgmqdlj3359rz5jgb0f5y8";
      type = "gem";
    };
    version = "1.8.1";
  };
  redis-store = {
    dependencies = ["redis"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0cpzbf2svnk4j5awb24ncl0mih45zkbdrd7q23jdg1r8k3q7mdg6";
      type = "gem";
    };
    version = "1.9.0";
  };
  regexp_parser = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0vg7imjnfcqjx7kw94ccj5r78j4g190cqzi1i59sh4a0l940b9cr";
      type = "gem";
    };
    version = "2.1.1";
  };
  remote_lock = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0xk55hnzdi96r4y7x0agqi6kdrhwhshhj42lwyhiw17ar2pd0f4p";
      type = "gem";
    };
    version = "1.1.0";
  };
  remote_syslog_logger = {
    dependencies = ["syslog_protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1g8h2rfw80ay5yqaj8wddagpagpznk403pxnw6wcxvazrwqcb9h2";
      type = "gem";
    };
    version = "1.0.4";
  };
  representable = {
    dependencies = ["declarative" "trailblazer-option" "uber"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "09xwzz94ryp57wyjrqysiz1sslnxd4r4m9wayy63jb7f8qfx1kys";
      type = "gem";
    };
    version = "3.1.1";
  };
  request_store = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0cx74kispmnw3ljwb239j65a2j14n8jlsygy372hrsa8mxc71hxi";
      type = "gem";
    };
    version = "1.5.0";
  };
  responders = {
    dependencies = ["actionpack" "railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "14kjykc6rpdh24sshg9savqdajya2dislc1jmbzg91w9967f4gv1";
      type = "gem";
    };
    version = "3.0.1";
  };
  rest-client = {
    dependencies = ["http-cookie" "mime-types" "netrc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1hzcs2r7b5bjkf2x2z3n8z6082maz0j8vqjiciwgg3hzb63f958j";
      type = "gem";
    };
    version = "2.0.2";
  };
  restforce = {
    dependencies = ["faraday" "faraday_middleware" "hashie" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0qm9fb811kzmvd7ci94riv8m8im7210v18ca87r5qy2ijvxc8sci";
      type = "gem";
    };
    version = "2.5.3";
  };
  retriable = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1q48hqws2dy1vws9schc0kmina40gy7sn5qsndpsfqdslh65snha";
      type = "gem";
    };
    version = "3.1.2";
  };
  rexml = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "08ximcyfjy94pm1rhcx04ny1vx2sk0x4y185gzn86yfsbzwkng53";
      type = "gem";
    };
    version = "3.2.5";
  };
  rly = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1sj2j7ggnkqh922x1f19dfzcpjxny7hggdh4b3ydgrb35v9c7gki";
      type = "gem";
    };
    version = "0.2.3";
  };
  rollbar = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0nx2v9l9f152aaxcfd9g2in8jhfwq3jqk3z1sk2mcjnf0b490vch";
      type = "gem";
    };
    version = "3.2.0";
  };
  rspec = {
    dependencies = ["rspec-core" "rspec-expectations" "rspec-mocks"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1dwai7jnwmdmd7ajbi2q0k0lx1dh88knv5wl7c34wjmf94yv8w5q";
      type = "gem";
    };
    version = "3.10.0";
  };
  rspec-activemodel-mocks = {
    dependencies = ["activemodel" "activesupport" "rspec-mocks"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1n848zldby8agx3409c06qix90zs73ik0wsz8w9xpjqa81nxjcap";
      type = "gem";
    };
    version = "1.1.0";
  };
  rspec-core = {
    dependencies = ["rspec-support"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0wwnfhxxvrlxlk1a3yxlb82k2f9lm0yn0598x7lk8fksaz4vv6mc";
      type = "gem";
    };
    version = "3.10.1";
  };
  rspec-expectations = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1sz9bj4ri28adsklnh257pnbq4r5ayziw02qf67wry0kvzazbb17";
      type = "gem";
    };
    version = "3.10.1";
  };
  rspec-mocks = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1d13g6kipqqc9lmwz5b244pdwc97z15vcbnbq6n9rlf32bipdz4k";
      type = "gem";
    };
    version = "3.10.2";
  };
  rspec-rails = {
    dependencies = ["actionpack" "activesupport" "railties" "rspec-core" "rspec-expectations" "rspec-mocks" "rspec-support"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1pj2a9vrkp2xzlq0810q90sdc2zcqc7k92n57hxzhri2vcspy7n6";
      type = "gem";
    };
    version = "5.0.1";
  };
  rspec-sorbet = {
    dependencies = ["sorbet" "sorbet-runtime"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0kph8z97mrny3qgxgnv6qakl6bqpdpl6y0ri1bjnshk37ws5kv3z";
      type = "gem";
    };
    version = "1.8.0";
  };
  rspec-support = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "15j52parvb8cgvl6s0pbxi2ywxrv6x0764g222kz5flz0s4mycbl";
      type = "gem";
    };
    version = "3.10.2";
  };
  rspec_junit_formatter = {
    dependencies = ["rspec-core"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1aynmrgnv26pkprrajvp7advb8nbh0x4pkwk6jwq8qmwzarzk21p";
      type = "gem";
    };
    version = "0.4.1";
  };
  rubocop = {
    dependencies = ["parallel" "parser" "rainbow" "regexp_parser" "rexml" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0ijpwsxw05b31c2djs6jj68j1nchnc61h7wfnd524jpkhw8lsg12";
      type = "gem";
    };
    version = "1.16.0";
  };
  rubocop-ast = {
    dependencies = ["parser"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1hnrfy928mwpa0ippqs4s8xwghwwp5h853naphgqxcd53l33chlv";
      type = "gem";
    };
    version = "1.7.0";
  };
  rubocop-rails = {
    dependencies = ["activesupport" "rack" "rubocop"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1h8k2i6qgl7pdvb8bnh1w43zqdxqg3kglyxy9b2vdh2w7q5rrl5y";
      type = "gem";
    };
    version = "2.10.1";
  };
  rubocop-rspec = {
    dependencies = ["rubocop" "rubocop-ast"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0r69qcwm74vsbp1s2gaqaf91kkrsn2mv4gk6rvfb2pxzmgyi0r9g";
      type = "gem";
    };
    version = "2.3.0";
  };
  ruby-next-core = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "131q8n3zv4nmfd6qmz97za7srb3ygdj1icmc6ml81bqpn79gfcmz";
      type = "gem";
    };
    version = "0.12.0";
  };
  ruby-progressbar = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "02nmaw7yx9kl7rbaan5pl8x5nn0y4j5954mzrkzi9i3dhsrps4nc";
      type = "gem";
    };
    version = "1.11.0";
  };
  ruby-vips = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1zd93idvk2qs3accbfg7g77fb02k8qlrq1arqm4bbx2ylk9j66kf";
      type = "gem";
    };
    version = "2.1.2";
  };
  ruby2_keywords = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "15wfcqxyfgka05v2a7kpg64x57gl1y4xzvnc9lh60bqx5sf1iqrs";
      type = "gem";
    };
    version = "0.0.4";
  };
  ruby_http_client = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "00zysvpww8lb5wj94hi0x5ankahhj5kwspjjac461bxzjc83rn6s";
      type = "gem";
    };
    version = "3.5.2";
  };
  rubystats = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "11q5a46qywp4yhicqn0cgdaxg6vr5kwy31r7rgq9y4y2s0nfqa6k";
      type = "gem";
    };
    version = "0.3.0";
  };
  rubyzip = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1qxc2zxwwipm6kviiar4gfhcakpx1jdcs89v6lvzivn5hq1xk78l";
      type = "gem";
    };
    version = "1.3.0";
  };
  s3_direct_upload = {
    dependencies = ["coffee-rails" "jquery-fileupload-rails" "rails" "sass-rails"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "1d633125cf39c04ae30c80f8e1765f21b191b02a";
      sha256 = "04a3drg7d073wx47fs4dzxm71m64vsqjvqz9cqm9rqyv2nhgz0cs";
      type = "git";
      url = "https://github.com/waynehoover/s3_direct_upload";
    };
    version = "0.1.7";
  };
  saas_internal_partnership_client = {
    dependencies = ["json" "typhoeus"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0c708s1wcwyavlx38233i6mj0ld49anljlkhqp1z830ly67i4mws";
      type = "gem";
    };
    version = "2.2.1";
  };
  salesforce_bulk_api = {
    dependencies = ["json" "xml-simple"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "092bpbvpqwq5bkcsxqfw6wj6b7ip4rxiqqhwrdaszhmlpbczffzc";
      type = "gem";
    };
    version = "1.0.0";
  };
  salesforce_bulk_query = {
    dependencies = ["json" "xml-simple"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "063yni6ngsdikdfmrw0bnm9g31wb53ghxps4qm2ihbplxbxvxaf5";
      type = "gem";
    };
    version = "0.2.0";
  };
  sass = {
    dependencies = ["sass-listen"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0p95lhs0jza5l7hqci1isflxakz83xkj97lkvxl919is0lwhv2w0";
      type = "gem";
    };
    version = "3.7.4";
  };
  sass-listen = {
    dependencies = ["rb-fsevent" "rb-inotify"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0xw3q46cmahkgyldid5hwyiwacp590zj2vmswlll68ryvmvcp7df";
      type = "gem";
    };
    version = "4.0.0";
  };
  sass-rails = {
    dependencies = ["sassc-rails"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1lqhb0fgmls9l9jhgz42ri25w13q5pmsiiwzjbarz4n7l6749dp0";
      type = "gem";
    };
    version = "6.0.0";
  };
  sassc = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0gpqv48xhl8mb8qqhcifcp0pixn206a7imc07g48armklfqa4q2c";
      type = "gem";
    };
    version = "2.4.0";
  };
  sassc-rails = {
    dependencies = ["railties" "sassc" "sprockets" "sprockets-rails" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1d9djmwn36a5m8a83bpycs48g8kh1n2xkyvghn7dr6zwh4wdyksz";
      type = "gem";
    };
    version = "2.1.2";
  };
  savon = {
    dependencies = ["akami" "builder" "gyoku" "httpi" "nokogiri" "nori" "wasabi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "19ry5ww84bv31k5617p5k7qpdyar4fqjxhvk54vfgcwkg7nlan2h";
      type = "gem";
    };
    version = "2.12.1";
  };
  secure_headers = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "172q4jhdwn0ykrwlly6ykscwmgl03w770rr76sgagkywvpmiyakd";
      type = "gem";
    };
    version = "6.3.2";
  };
  seedbank = {
    dependencies = ["rake"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0dzlam41h872ly9x60wm0f4xqxmcxv7fxv2zh709mb176jzw0h4q";
      type = "gem";
    };
    version = "0.5.0";
  };
  select2-rails = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1jwj4mrlh33sbkkn9bldnsmxbd5c55jv79wm8qi41wj277ncdljf";
      type = "gem";
    };
    version = "3.5.11";
  };
  selenium-webdriver = {
    dependencies = ["childprocess" "rubyzip"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0adcvp86dinaqq3nhf8p3m0rl2g6q0a4h52k0i7kdnsg1qz9k86y";
      type = "gem";
    };
    version = "3.142.7";
  };
  semantic_range = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1dlp97vg95plrsaaqj7x8l7z9vsjbhnqk4rw1l30gy26lmxpfrih";
      type = "gem";
    };
    version = "3.0.0";
  };
  semian = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "13mlccf70slrjpxvpvmnk2cls39nkpgksa7sd90jlnm0s0z7lhdd";
      type = "gem";
    };
    version = "0.11.4";
  };
  sendgrid-ruby = {
    dependencies = ["ruby_http_client"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1rw1d9ppyhqxrpg8vc722mkfjk6afav8920miqzs1nyr7yay75ki";
      type = "gem";
    };
    version = "6.2.1";
  };
  sendgrid4r = {
    dependencies = ["rest-client"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "11brd8n2cxzrpsbgd8figgr5fhxb1ws63yz4xb7l7i3gv02gvsyp";
      type = "gem";
    };
    version = "1.15.0";
  };
  sendgrid_webapi = {
    dependencies = ["faraday" "faraday_middleware" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "12hpi2y22xxz8lvc02naqrrjkb44xpy5zl5d00p9z2gnz8v6naw1";
      type = "gem";
    };
    version = "0.0.8";
  };
  sequel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "010p4a60npppvgbyw7pq5xia8aydpgxdlhh3qjm2615kwjsw3fl8";
      type = "gem";
    };
    version = "4.49.0";
  };
  shoulda-matchers = {
    dependencies = ["activesupport"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1qi7gzli00mqlaq9an28m6xd323k7grgq19r6dqa2amjnnxy41ld";
      type = "gem";
    };
    version = "4.5.1";
  };
  sidekiq = {
    dependencies = ["connection_pool" "rack" "redis"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1ac57q6lnqg9h9lsj49wlwhgsfqfr83lgka1c1srk6g8vghhz662";
      type = "gem";
    };
    version = "6.2.1";
  };
  sidekiq-pro = {
    dependencies = ["connection_pool" "sidekiq"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0id6vm8x7idsgjvywj19wlivjjap71mp3zrsjm6fdrhnkm5ihfk7";
      type = "gem";
    };
    version = "5.2.2";
  };
  signet = {
    dependencies = ["addressable" "faraday" "jwt" "multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1vvxmfm9khxp35xs8qxc82i7hakylxbn7kx4apinvxaid6rlq60g";
      type = "gem";
    };
    version = "0.15.0";
  };
  simple_oauth = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0dw9ii6m7wckml100xhjc6vxpjcry174lbi9jz5v7ibjr3i94y8l";
      type = "gem";
    };
    version = "0.3.1";
  };
  simplecov = {
    dependencies = ["docile" "simplecov-html" "simplecov_json_formatter"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1hrv046jll6ad1s964gsmcq4hvkr3zzr6jc7z1mns22mvfpbc3cr";
      type = "gem";
    };
    version = "0.21.2";
  };
  simplecov-html = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0yx01bxa8pbf9ip4hagqkp5m0mqfnwnw2xk8kjraiywz4lrss6jb";
      type = "gem";
    };
    version = "0.12.3";
  };
  simplecov_json_formatter = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "19r15hyvh52jx7fmsrcflb58xh8l7l0zx4sxkh3hqzhq68y81pjl";
      type = "gem";
    };
    version = "0.1.3";
  };
  sinatra = {
    dependencies = ["mustermann" "rack" "rack-protection" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0dd53rzpkxgs697pycbhhgc9vcnxra4ly4xar8ni6aiydx2f88zk";
      type = "gem";
    };
    version = "2.1.0";
  };
  site_prism = {
    dependencies = ["addressable" "capybara" "site_prism-all_there"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1w71r6rgs76gjfrk5gxgpr4ph2k7rrkgga87lap2ifn5zyxzjzq1";
      type = "gem";
    };
    version = "3.7.1";
  };
  site_prism-all_there = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1xkmxlwpb06fm4xi6qkr0bc5js8gvz3ygfw0cf0ki3l4g66amph2";
      type = "gem";
    };
    version = "0.3.2";
  };
  sixarm_ruby_unaccent = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "11237b8r8p7fc0cpn04v9wa7ggzq0xm6flh10h1lnb6zgc3schq0";
      type = "gem";
    };
    version = "1.2.0";
  };
  smart_properties = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0vi2hhyqf6xvds03bh8ydrbydq5748f1nfgamy16400v1azsag57";
      type = "gem";
    };
    version = "1.15.0";
  };
  socksify = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1fp4p8p4y713lh00rd31xymxnzkbhmg0d12ixbqs7lcaj2pcgcni";
      type = "gem";
    };
    version = "1.7.1";
  };
  sorbet = {
    dependencies = ["sorbet-static"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1irzxjrfykm7zdda570p54sb639jk54myzkqyr8qvni3ycpkqbfg";
      type = "gem";
    };
    version = "0.5.6433";
  };
  sorbet-runtime = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "02s1ssnglai9fldw363q56ynk26lai9bpc9kw937bg10iwvyk6wg";
      type = "gem";
    };
    version = "0.5.6433";
  };
  sorbet-static = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems"];
      sha256 = "1k83cczx26smxpkmqd8f2i56sfbbjpdj9imhz3as4xqp50dvlbdf";
      type = "gem";
    };
    version = "0.5.6433-x86_64-linux";
  };
  sort_alphabetical = {
    dependencies = ["unicode_utils"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1gdkawrxig86w9agy7fgvc9qmypvln63nj32h5yz79fgflazzmxf";
      type = "gem";
    };
    version = "1.1.0";
  };
  spf-query = {
    dependencies = ["parslet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0ixgk4315yxpz2dkr3s9hv7yxckk96prjaqc4kpq6giaa4nhvsfp";
      type = "gem";
    };
    version = "0.1.5";
  };
  split = {
    dependencies = ["redis" "rubystats" "sinatra"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0n8zfxv54kfgdih1ghc3kazqdjls7smi9b3gd8jivl3ws3hb2jhz";
      type = "gem";
    };
    version = "4.0.0.pre";
  };
  spring = {
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1x2wz1y2b0kp7mlk9k8zkl39rddk2l3x34b7dar3bh3axd1cs30d";
      type = "gem";
    };
    version = "2.1.1";
  };
  spring-commands-cucumber = {
    dependencies = ["spring"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0mw81gvms2svn4k4pc6ly7smkmf0j9r2xbf0d38vygbyhiwd1c9a";
      type = "gem";
    };
    version = "1.0.1";
  };
  spring-commands-rspec = {
    dependencies = ["spring"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0b0svpq3md1pjz5drpa5pxwg8nk48wrshq8lckim4x3nli7ya0k2";
      type = "gem";
    };
    version = "1.0.4";
  };
  sprockets = {
    dependencies = ["concurrent-ruby" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "182jw5a0fbqah5w9jancvfmjbk88h8bxdbwnl4d3q809rpxdg8ay";
      type = "gem";
    };
    version = "3.7.2";
  };
  sprockets-rails = {
    dependencies = ["actionpack" "activesupport" "sprockets"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0mwmz36265646xqfyczgr1mhkm1hfxgxxvgdgr4xfcbf2g72p1k2";
      type = "gem";
    };
    version = "3.2.2";
  };
  ssrf_filter = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0flmg6f444liaxjgdwdrwcfwyyhc54a7wp26kqih2cklwll5gp40";
      type = "gem";
    };
    version = "1.0.7";
  };
  sugarcrm = {
    dependencies = ["activesupport" "i18n" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "066c35izrg3k6nqp2aiglf8akr8lncxzjfs3z4jc42f2w3h3cr7i";
      type = "gem";
    };
    version = "0.9.18";
  };
  sync = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1z9qlq4icyiv3hz1znvsq1wz2ccqjb1zwd6gkvnwg6n50z65d0v6";
      type = "gem";
    };
    version = "0.5.0";
  };
  sys-uname = {
    dependencies = ["ffi"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0gk625krfm00nppb2ni0794kzr1cqbs1a0059fhp4s3lcrmx69jc";
      type = "gem";
    };
    version = "1.2.2";
  };
  syslog_protocol = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1yb2cmbyj0zmb2yhkgnmghcngrkhcxs4g1svcmgfj90l2hs23nmc";
      type = "gem";
    };
    version = "0.9.2";
  };
  table_print = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1jxmd1yg3h0g27wzfpvq1jnkkf7frwb5wy9m4f47nf4k3wl68rj3";
      type = "gem";
    };
    version = "1.5.7";
  };
  term-ansicolor = {
    dependencies = ["tins"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1xq5kci9215skdh27npyd3y55p812v4qb4x2hv3xsjvwqzz9ycwj";
      type = "gem";
    };
    version = "1.7.1";
  };
  terminal-table = {
    dependencies = ["unicode-display_width"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1512cngw35hsmhvw4c05rscihc59mnj09m249sm9p3pik831ydqk";
      type = "gem";
    };
    version = "1.8.0";
  };
  thor = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "18yhlvmfya23cs3pvhr1qy38y41b6mhr5q9vwv5lrgk16wmf3jna";
      type = "gem";
    };
    version = "1.1.0";
  };
  thread_safe = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0nmhcgq6cgz44srylra07bmaw99f5271l0dpsvl5f75m44l0gmwy";
      type = "gem";
    };
    version = "0.3.6";
  };
  thrift = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1sfa4120a7yl3gxjcx990gyawsshfr22gfv5rvgpk72l2p9j2420";
      type = "gem";
    };
    version = "0.14.1";
  };
  tilt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0rn8z8hda4h41a64l0zhkiwz2vxw9b1nb70gl37h1dg2k874yrlv";
      type = "gem";
    };
    version = "2.0.10";
  };
  timeline-swagger-client = {
    dependencies = ["json" "typhoeus"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "04q3dfh57a6dr6llr8fk6c3lkmphfyr8z2khb4rrr274yf7n35sb";
      type = "gem";
    };
    version = "0.5.0";
  };
  tins = {
    dependencies = ["sync"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0nzp88y19rqlcizp1nw8m44fvfxs9g3bhjpscz44dwfawfrmr0cb";
      type = "gem";
    };
    version = "1.29.1";
  };
  tinymce-rails = {
    dependencies = ["railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0sxx4wcllshk1ki51p508ysb1crdwbch1db189nn4gcy5lvmvxsx";
      type = "gem";
    };
    version = "4.6.5";
  };
  tinymce-rails-langs = {
    dependencies = ["tinymce-rails"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1ld2h4d0h56366q1jj7xg4g4c7xpg7cmiwa28qjx3s1000fmav6w";
      type = "gem";
    };
    version = "4.20190124";
  };
  todo_list_client = {
    dependencies = ["json" "typhoeus"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0n289ss1d6iafihzf3wq525n10rckfib736q9f3f3qxsd9wm2qvc";
      type = "gem";
    };
    version = "1.0.9";
  };
  traffic_source_parser = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0p2cv1ziyjbn6gly6a36fajr1r55yja1qjcdj516hrkz965bx0qf";
      type = "gem";
    };
    version = "0.4.3";
  };
  trailblazer-option = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0ydsr9r870d67zbirfanlazba5q0gjf4zb89hn4iy28fs9v9riar";
      type = "gem";
    };
    version = "0.1.1";
  };
  tty-cursor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0j5zw041jgkmn605ya1zc151bxgxl6v192v2i26qhxx7ws2l2lvr";
      type = "gem";
    };
    version = "0.7.1";
  };
  tty-spinner = {
    dependencies = ["tty-cursor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0hh5awmijnzw9flmh5ak610x1d00xiqagxa5mbr63ysggc26y0qf";
      type = "gem";
    };
    version = "0.9.3";
  };
  twitter = {
    dependencies = ["addressable" "buftok" "equalizer" "http" "http-form_data" "http_parser.rb" "memoizable" "multipart-post" "naught" "simple_oauth"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "13dmkjgsnym1avym9f7y2i2h3mlk8crqvc87drrzr4f0sf9l8g2y";
      type = "gem";
    };
    version = "7.0.0";
  };
  typhoeus = {
    dependencies = ["ethon"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1m22yrkmbj81rzhlny81j427qdvz57yk5wbcf3km0nf3bl6qiygz";
      type = "gem";
    };
    version = "1.4.0";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "10qp5x7f9hvlc0psv9gsfbxg4a7s0485wsbq1kljkxq94in91l4z";
      type = "gem";
    };
    version = "2.0.4";
  };
  uber = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1p1mm7mngg40x05z52md3mbamkng0zpajbzqjjwmsyw0zw3v9vjv";
      type = "gem";
    };
    version = "0.1.0";
  };
  uglifier = {
    dependencies = ["execjs"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0wgh7bzy68vhv9v68061519dd8samcy8sazzz0w3k8kqpy3g4s5f";
      type = "gem";
    };
    version = "4.2.0";
  };
  unf = {
    dependencies = ["unf_ext"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
    version = "0.1.4";
  };
  unf_ext = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0wc47r23h063l8ysws8sy24gzh74mks81cak3lkzlrw4qkqb3sg4";
      type = "gem";
    };
    version = "0.0.7.7";
  };
  unicode-display_width = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "06i3id27s60141x6fdnjn5rar1cywdwy64ilc59cz937303q3mna";
      type = "gem";
    };
    version = "1.7.0";
  };
  unicode_utils = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0h1a5yvrxzlf0lxxa1ya31jcizslf774arnsd89vgdhk4g7x08mr";
      type = "gem";
    };
    version = "1.4.0";
  };
  upperkut = {
    dependencies = ["connection_pool" "redis"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1y71mzmnifhcmh8hvjjwqjj2fysr7jwygf337cq8536kdnnx0jv4";
      type = "gem";
    };
    version = "1.0.2";
  };
  uri_template = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0p8qbxlpmg3msw0ihny6a3gsn0yvydx9ksh5knn8dnq06zhqyb1i";
      type = "gem";
    };
    version = "0.7.0";
  };
  valid_kit = {
    dependencies = ["jsonpath"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0j4d9g83g4zicggb5df5743iz32pr1bnrwpfqlhzslfymsjz6dl1";
      type = "gem";
    };
    version = "1.6.3";
  };
  validates_email_format_of = {
    dependencies = ["i18n"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "16hvm3rxys976xvijsyancd17wdy8rq6akgm0r4avr7pq087mskj";
      type = "gem";
    };
    version = "1.6.3";
  };
  vcr = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1dxsb3a8ng3ibz0z200qwcc3zzqc013bs59gn6cxh68iilnz9d9q";
      type = "gem";
    };
    version = "5.1.0";
  };
  versionist = {
    dependencies = ["activesupport" "railties" "yard"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1y253qhn66s4s124zh81nrjvzvb9b2zax23m6chhw0qx1mlyjffx";
      type = "gem";
    };
    version = "2.0.1";
  };
  wasabi = {
    dependencies = ["addressable" "httpi" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "1rzmh6knnj8pmw6slc6393dxpb6k47lcac3889i7g5nyhfcn9xbp";
      type = "gem";
    };
    version = "3.6.1";
  };
  web_analytics = {
    groups = ["default"];
    platforms = [];
    source = {
      path = components/web_analytics;
      type = "path";
    };
    version = "0.0.1";
  };
  webmock = {
    dependencies = ["addressable" "crack" "hashdiff"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "17j3vvzdvdjmaqzjmsrm5i9sg3vv7r4b9g6ayri462h1dxnvb4li";
      type = "gem";
    };
    version = "3.11.3";
  };
  webpacker = {
    dependencies = ["activesupport" "rack-proxy" "railties" "semantic_range"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0bs6m6annfb2pazb5wb2l3lbnkaa4438ixldnamlx9hg7z3j646h";
      type = "gem";
    };
    version = "5.4.0";
  };
  webrick = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1d4cvgmxhfczxiq5fr534lmizkhigd15bsx5719r5ds7k7ivisc7";
      type = "gem";
    };
    version = "1.7.0";
  };
  websocket-driver = {
    dependencies = ["websocket-extensions"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0l1wmvs0yf8gz64rymijx2pygwch99qdci91q8j193fwrz22bp7x";
      type = "gem";
    };
    version = "0.7.4";
  };
  websocket-extensions = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      type = "gem";
    };
    version = "0.1.5";
  };
  wicked = {
    dependencies = ["railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0ck6cz3ybki0vyyz9rpv938brn2zbi9ik6hi21zgn5sv594rb06q";
      type = "gem";
    };
    version = "1.3.4";
  };
  will_paginate = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "10qk4mf3rfc0vr26j0ba6vcz7407rdjfn13ph690pkzr94rv8bay";
      type = "gem";
    };
    version = "3.3.0";
  };
  will_paginate-bootstrap = {
    dependencies = ["will_paginate"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org"];
      sha256 = "0vfazcygfgrwp26pzx9isbgbvbiqxmd5jq9cl19gz3vfv089z60p";
      type = "gem";
    };
    version = "1.0.2";
  };
  will_paginate_mongoid = {
    dependencies = ["mongoid" "will_paginate"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0vl50wlnm6wgi39n8qxzas3xww6cq8b2v05l4828jk7lxb1w57ls";
      type = "gem";
    };
    version = "2.0.1";
  };
  workflow_templates = {
    dependencies = ["rails"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0brib1csgzidlxygm934w438l46ybxz70l0ln38xs4h4smvjix0n";
      type = "gem";
    };
    version = "0.9.0";
  };
  xml-simple = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1flpmghcbil6qbl3f6w67kpjrnjbw86x7h6g5n4m5ff0cg4sylrv";
      type = "gem";
    };
    version = "1.1.8";
  };
  xpath = {
    dependencies = ["nokogiri"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0bh8lk9hvlpn7vmi6h4hkcwjzvs2y0cmkk3yjjdr8fxvj6fsgzbd";
      type = "gem";
    };
    version = "3.2.0";
  };
  yard = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "0qzr5j1a1cafv81ib3i51qyl8jnmwdxlqi3kbiraldzpbjh4ln9h";
      type = "gem";
    };
    version = "0.9.26";
  };
  zeitwerk = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems" "https://rubygems.org" "https://resultadosdigitais.jfrog.io/resultadosdigitais/api/gems/gems-contribsys-remote"];
      sha256 = "1746czsjarixq0x05f7p3hpzi38ldg6wxnxxw74kbjzh1sdjgmpl";
      type = "gem";
    };
    version = "2.4.2";
  };
}
