# pick "key": the phrases.nix entry as a Home Assistant template that says
# one of its variants at random. Variables a phrase uses ({{ level }}, ...)
# are set by the caller in front of it ("{% set level = ... %}").
let
  phrases = import ./phrases.nix;
  pick = key:
    let
      vs = phrases.${key};
      n = builtins.length vs;
      branch = i: (if i == 0 then "{% if _v == 0 %}" else "{% elif _v == ${toString i} %}") + builtins.elemAt vs i;
    in
    if n == 1 then builtins.head vs
    else "{% set _v = range(${toString n}) | random %}" + builtins.concatStringsSep "" (builtins.genList branch n) + "{% endif %}";
in
{ inherit phrases pick; }
