{ pkgs, ...}:

{
  home.file.".google-cloud-sdk-installer.tar.gz" = {
    source =  pkgs.fetchurl {
      url = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-350.0.0-linux-x86_64.tar.gz";
      sha256 =  "1vlcwab68d8rpzkjcwj83qn35bq0awsl15p35x5qpsymmvf046l6";
    };
    onChange =  "${pkgs.writeShellScript "google-cloud-sdk-change" ''
      tar xf ~/.google-cloud-sdk-installer.tar.gz
      ~/google-cloud-sdk/bin/gcloud components install cbt
    ''}";
  };
}
