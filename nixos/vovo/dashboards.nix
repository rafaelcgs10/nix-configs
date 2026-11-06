{ config, lib, pkgs, ... }:

# Home Assistant sidebar entries, declarative (YAML dashboards):
#  - "vovo": what is playing, playback/volume controls and one button per
#    mood (moods.nix) and a few voice commands; buttons send the same text
#    to Assist as saying it, so they behave exactly like the voice commands;
#  - "Music Assistant": Music Assistant's own web UI inside Home Assistant
#    (log in there once; "Home Assistant" is offered as a login method).
# HA's built-in "Media" panel also browses the Music Assistant library.
let
  player = "media_player.vovo";
  yaml = pkgs.formats.yaml { };

  say = text: {
    action = "perform-action";
    perform_action = "conversation.process";
    data = { inherit text; language = "en"; };
  };
  button = name: icon: text: {
    type = "button";
    inherit name icon;
    show_state = false;
    tap_action = say text;
  };

  moodIcons = {
    lofi = "mdi:headphones";
    "romantic piano" = "mdi:piano";
    romantic = "mdi:heart";
    calm = "mdi:weather-night";
    stretching = "mdi:yoga";
    morning = "mdi:weather-sunset-up";
  };
  moods = builtins.attrNames (import ./moods.nix);

  vovo = yaml.generate "vovo-dashboard.yaml" {
    title = "vovo";
    views = [
      {
        title = "vovo";
        path = "vovo";
        cards = [
          { type = "media-control"; entity = player; }
          {
            type = "grid";
            title = "Moods";
            columns = 3;
            square = false;
            cards = map (m: button m (moodIcons.${m} or "mdi:music") "play some ${m}") moods;
          }
          {
            type = "grid";
            title = "Controls";
            columns = 4;
            square = false;
            cards = [
              (button "Shuffle library" "mdi:shuffle-variant" "play something")
              (button "Next" "mdi:skip-next" "next")
              (button "Stop" "mdi:stop" "stop")
              (button "What's playing" "mdi:information-outline" "what's playing")
            ];
          }
        ];
      }
    ];
  };

  musicAssistant = yaml.generate "music-assistant-dashboard.yaml" {
    title = "Music Assistant";
    views = [
      {
        title = "Music Assistant";
        path = "music-assistant";
        panel = true;
        cards = [ { type = "iframe"; url = "http://vovo.local:8095"; aspect_ratio = "100%"; } ];
      }
    ];
  };
in
{
  services.home-assistant.config.lovelace.dashboards = {
    vovo-music = {
      mode = "yaml";
      filename = "dashboards/vovo.yaml";
      title = "vovo";
      icon = "mdi:speaker";
      show_in_sidebar = true;
    };
    music-assistant = {
      mode = "yaml";
      filename = "dashboards/music-assistant.yaml";
      title = "Music Assistant";
      icon = "mdi:music-circle";
      show_in_sidebar = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hass/dashboards 0755 hass hass -"
    "L+ /var/lib/hass/dashboards/vovo.yaml - - - - ${vovo}"
    "L+ /var/lib/hass/dashboards/music-assistant.yaml - - - - ${musicAssistant}"
  ];
}
