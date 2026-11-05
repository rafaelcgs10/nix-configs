{ config, lib, pkgs, ... }:

# Home Assistant at http://vovo.local:8123.
#
# Deliberately without `default_config`: that would load ~40 integrations,
# including HA's own Bluetooth stack (which would fight PipeWire over the
# adapter). Only what the voice music box needs is loaded.
#
# Everything here is declarative except what HA keeps in its own database:
# the owner account (created in the browser on first visit) and the
# integration entries (Wyoming services, Music Assistant), see README.
let
  # The Squeezelite player as Music Assistant exposes it in Home Assistant.
  player = "media_player.vovo";
in
{
  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraComponents = [
      # what the onboarding wizard sets up by default (avoids errors there)
      "met"
      "radio_browser"
      "shopping_list"
      "google_translate"
      "isal"
      # voice + music
      "assist_pipeline"
      "assist_satellite"
      "conversation"
      "stt"
      "tts"
      "wake_word"
      "wyoming"
      "music_assistant"
      "media_player"
      "zeroconf"
    ];

    config = {
      homeassistant = {
        name = "vovo";
        unit_system = "metric";
        time_zone = "Europe/Copenhagen";
        country = "DK";
        currency = "DKK";
      };
      frontend = { };
      config = { };
      http = { };
      zeroconf = { };
      assist_pipeline = { };
      conversation = { };
      system_health = { };

      # Small history, written rarely: spares the SD card and RAM.
      recorder = {
        purge_keep_days = 2;
        commit_interval = 30;
      };

      # UI-made automations/scripts still work (files created below).
      "automation ui" = "!include automations.yaml";
      "script ui" = "!include scripts.yaml";

      "automation nixos" = [
        {
          id = "vovo_play_song";
          alias = "vovo - play a song";
          mode = "single";
          triggers = [
            {
              trigger = "conversation";
              command = [
                "play {song}"
                "put on {song}"
                "I want to (hear|listen to) {song}"
              ];
            }
          ];
          actions = [
            {
              variables = {
                inherit player;
                ma_entry = "{{ config_entry_id(player) }}";
                song = "{{ trigger.slots.song | trim }}";
              };
            }
            # "play something" / "play some music" -> random song from the library
            {
              "if" = [
                {
                  condition = "template";
                  value_template = "{{ song | lower in ['something', 'some music', 'music', 'anything', 'a song', 'random', 'random music'] }}";
                }
              ];
              "then" = [
                {
                  action = "music_assistant.get_library";
                  data = {
                    config_entry_id = "{{ ma_entry }}";
                    media_type = "track";
                    order_by = "random";
                    limit = 1;
                  };
                  response_variable = "lib";
                }
                {
                  action = "music_assistant.play_media";
                  target.entity_id = "{{ player }}";
                  data = {
                    media_id = "{{ lib['items'][0].uri }}";
                    media_type = "track";
                  };
                }
                { set_conversation_response = "Here's {{ lib['items'][0].name }} from your library."; }
                { stop = "random"; }
              ];
            }
            # 1) the local library
            {
              action = "music_assistant.search";
              data = {
                config_entry_id = "{{ ma_entry }}";
                name = "{{ song }}";
                media_type = "track";
                library_only = true;
                limit = 1;
              };
              response_variable = "local";
            }
            {
              "if" = [
                {
                  condition = "template";
                  value_template = "{{ local.tracks | length > 0 }}";
                }
              ];
              "then" = [
                {
                  action = "music_assistant.play_media";
                  target.entity_id = "{{ player }}";
                  data = {
                    media_id = "{{ local.tracks[0].uri }}";
                    media_type = "track";
                  };
                }
                {
                  set_conversation_response = "Playing {{ local.tracks[0].name }} by {{ local.tracks[0].artists | map(attribute='name') | join(' and ') }}.";
                }
              ];
              "else" = [
                # 2) not in the library: everything else (YouTube Music)
                {
                  action = "music_assistant.search";
                  data = {
                    config_entry_id = "{{ ma_entry }}";
                    name = "{{ song }}";
                    media_type = "track";
                    library_only = false;
                    limit = 1;
                  };
                  response_variable = "online";
                }
                {
                  "if" = [
                    {
                      condition = "template";
                      value_template = "{{ online.tracks | length > 0 }}";
                    }
                  ];
                  "then" = [
                    {
                      action = "music_assistant.play_media";
                      target.entity_id = "{{ player }}";
                      data = {
                        media_id = "{{ online.tracks[0].uri }}";
                        media_type = "track";
                      };
                    }
                    {
                      set_conversation_response = "I didn't have {{ online.tracks[0].name }} in your library, so I'm playing it from YouTube.";
                    }
                  ];
                  # 3) nowhere: explain
                  "else" = [
                    {
                      set_conversation_response = "Sorry, I couldn't find {{ song }} in your library or on YouTube. Try saying the artist too, like: play Imagine by John Lennon.";
                    }
                  ];
                }
              ];
            }
          ];
        }

        {
          id = "vovo_small_talk";
          alias = "vovo - small talk";
          mode = "single";
          triggers = [
            { trigger = "conversation"; command = [ "hello" "hi [there]" "good morning" "good evening" ]; id = "hello"; }
            { trigger = "conversation"; command = [ "what can you do" "help" ]; id = "help"; }
            { trigger = "conversation"; command = [ "what's playing" "what is playing" "what song is this" "who sings this" ]; id = "now_playing"; }
            { trigger = "conversation"; command = [ "thank you" "thanks" ]; id = "thanks"; }
          ];
          actions = [
            { variables = { inherit player; }; }
            {
              choose = [
                {
                  conditions = "{{ trigger.id == 'hello' }}";
                  sequence = [ { set_conversation_response = "Hi! Tell me a song and I'll play it."; } ];
                }
                {
                  conditions = "{{ trigger.id == 'help' }}";
                  sequence = [
                    {
                      set_conversation_response = "Say play and a song name, or play something for a random song. You can also ask what's playing, or say pause, next, or volume up.";
                    }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'now_playing' }}";
                  sequence = [
                    {
                      set_conversation_response = "{% if is_state(player, 'playing') %}This is {{ state_attr(player, 'media_title') }} by {{ state_attr(player, 'media_artist') }}.{% else %}Nothing is playing right now.{% endif %}";
                    }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'thanks' }}";
                  sequence = [ { set_conversation_response = "You're welcome!"; } ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0644 hass hass"
    "f ${config.services.home-assistant.configDir}/scripts.yaml 0644 hass hass"
  ];

  systemd.services.home-assistant.serviceConfig.MemoryHigh = "450M";
}
