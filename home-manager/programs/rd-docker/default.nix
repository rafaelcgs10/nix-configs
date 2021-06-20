{ pkgs, ...}:

{
  home.file.".rd-docker-installer" = {
    source =  builtins.fetchGit {
      url = "ssh://git@github.com/ResultadosDigitais/rd-docker.git";
      rev = "cf1aeca3e9a5588d26360f3bb2618977cdceb247";
    };
    onChange =  "${pkgs.writeShellScript "rd-docker-change" ''
      cd ~/.rd-docker-installer
      cp rd-docker-install /tmp/rd-docker-install
      sed 's/sudo ln/# sudo ln/' -i /tmp/rd-docker-install
      cat /tmp/rd-docker-install | bash
    ''}";
  };
}
