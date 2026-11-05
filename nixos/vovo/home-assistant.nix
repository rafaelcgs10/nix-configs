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

  randomPhrases = "['something', 'some music', 'music', 'anything', 'a song', 'random', 'random music', 'my music', 'some songs']";

  # After a single requested song, queue 20 random library songs behind it so
  # the music keeps going and "next" has somewhere to go. (Music Assistant's
  # "don't stop the music" needs a streaming provider; local files don't do it.)
  fillQueue = [
    {
      action = "music_assistant.get_library";
      data = { config_entry_id = "{{ ma_entry }}"; media_type = "track"; order_by = "random"; limit = 20; };
      response_variable = "fill";
    }
    {
      action = "music_assistant.play_media";
      target.entity_id = "{{ player }}";
      data = { media_id = "{{ fill['items'] | map(attribute='uri') | list }}"; media_type = "track"; enqueue = "add"; };
    }
  ];
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

      input_number.vovo_volume_before_mute = {
        name = "vovo volume before mute";
        min = 0;
        max = 1;
        step = 0.01;
        initial = 0.6;
      };

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
          alias = "vovo - play music";
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
              # Nix emits attributes alphabetically, so a variable here
              # cannot refer to another one from the same block.
              variables = {
                inherit player;
                ma_entry = "{{ config_entry_id('${player}') }}";
                song = "{{ trigger.slots.song | trim }}";
              };
            }
            {
              variables = {
                # what kind of request:
                #   random  "play something", "play some music"
                #   artist  "play songs by X", "play music by X", "play some X"
                #   album   "play the album X"
                #   track   "play X", "play X by Y"
                mode = "{% set q = song | lower %}{% if q in ${randomPhrases} %}random{% elif q.startswith(('songs by ', 'music by ', 'something by ', 'anything by ', 'the artist ', 'artist ', 'some ')) %}artist{% elif q.startswith(('the album ', 'album ')) %}album{% else %}track{% endif %}";
                name = "{{ song | regex_replace('(?i)^(songs by|music by|something by|anything by|the artist|artist|some|the album|album)\\s+', '') | trim }}";
                title = "{{ (song.split(' by ') | first) | trim }}";
                artist = "{{ (song.split(' by ')[1] if ' by ' in song else '') | trim }}";
              };
            }
            {
              choose = [
                # --- random: shuffle 25 songs from the library ---------------
                {
                  conditions = "{{ mode == 'random' }}";
                  sequence = [
                    {
                      action = "music_assistant.get_library";
                      data = { config_entry_id = "{{ ma_entry }}"; media_type = "track"; order_by = "random"; limit = 25; };
                      response_variable = "lib";
                    }
                    {
                      action = "music_assistant.play_media";
                      target.entity_id = "{{ player }}";
                      data = { media_id = "{{ lib['items'] | map(attribute='uri') | list }}"; media_type = "track"; enqueue = "replace"; };
                    }
                    { set_conversation_response = "Shuffling your library. First up: {{ lib['items'][0].name }}."; }
                  ];
                }
                # --- artist: all their songs, shuffled -----------------------
                {
                  conditions = "{{ mode == 'artist' }}";
                  sequence = [
                    {
                      action = "music_assistant.search";
                      data = { config_entry_id = "{{ ma_entry }}"; name = "{{ name }}"; media_type = "artist"; library_only = true; limit = 1; };
                      response_variable = "found";
                    }
                    {
                      "if" = [ { condition = "template"; value_template = "{{ found.artists | length > 0 }}"; } ];
                      "then" = [
                        { action = "media_player.shuffle_set"; target.entity_id = "{{ player }}"; data.shuffle = true; }
                        {
                          action = "music_assistant.play_media";
                          target.entity_id = "{{ player }}";
                          data = { media_id = "{{ found.artists[0].uri }}"; media_type = "artist"; enqueue = "replace"; };
                        }
                        { set_conversation_response = "Playing music by {{ found.artists[0].name }}."; }
                      ];
                      "else" = [ { set_conversation_response = "Sorry, I don't have any music by {{ name }}."; } ];
                    }
                  ];
                }
                # --- album, in order --------------------------------------------
                {
                  conditions = "{{ mode == 'album' }}";
                  sequence = [
                    {
                      action = "music_assistant.search";
                      data = { config_entry_id = "{{ ma_entry }}"; name = "{{ name }}"; media_type = "album"; library_only = true; limit = 1; };
                      response_variable = "found";
                    }
                    {
                      "if" = [ { condition = "template"; value_template = "{{ found.albums | length > 0 }}"; } ];
                      "then" = [
                        { action = "media_player.shuffle_set"; target.entity_id = "{{ player }}"; data.shuffle = false; }
                        {
                          action = "music_assistant.play_media";
                          target.entity_id = "{{ player }}";
                          data = { media_id = "{{ found.albums[0].uri }}"; media_type = "album"; enqueue = "replace"; };
                        }
                        { set_conversation_response = "Playing the album {{ found.albums[0].name }} by {{ found.albums[0].artists | map(attribute='name') | join(' and ') }}."; }
                      ];
                      "else" = [ { set_conversation_response = "Sorry, I couldn't find the album {{ name }}."; } ];
                    }
                  ];
                }
              ];
              # --- a single song: library, then YouTube, then explain -------
              default = [
                {
                  action = "music_assistant.search";
                  data = { config_entry_id = "{{ ma_entry }}"; name = "{{ title }}"; artist = "{{ artist }}"; media_type = "track"; library_only = true; limit = 1; };
                  response_variable = "local";
                }
                {
                  "if" = [ { condition = "template"; value_template = "{{ local.tracks | length > 0 }}"; } ];
                  "then" = [
                    {
                      action = "music_assistant.play_media";
                      target.entity_id = "{{ player }}";
                      data = { media_id = "{{ local.tracks[0].uri }}"; media_type = "track"; enqueue = "replace"; };
                    }
                    { set_conversation_response = "Playing {{ local.tracks[0].name }} by {{ local.tracks[0].artists | map(attribute='name') | join(' and ') }}."; }
                  ]
                  ++ fillQueue;
                  "else" = [
                    {
                      action = "music_assistant.search";
                      data = { config_entry_id = "{{ ma_entry }}"; name = "{{ title }}"; artist = "{{ artist }}"; media_type = "track"; library_only = false; limit = 1; };
                      response_variable = "online";
                    }
                    {
                      "if" = [ { condition = "template"; value_template = "{{ online.tracks | length > 0 }}"; } ];
                      "then" = [
                        {
                          action = "music_assistant.play_media";
                          target.entity_id = "{{ player }}";
                          data = { media_id = "{{ online.tracks[0].uri }}"; media_type = "track"; enqueue = "replace"; };
                        }
                        { set_conversation_response = "I didn't have {{ online.tracks[0].name }} in your library, so I'm playing it from YouTube."; }
                      ]
                      ++ fillQueue;
                      "else" = [
                        { set_conversation_response = "Sorry, I couldn't find {{ song }} in your library. Try saying the artist too, like: play Numb by Linkin Park."; }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }

        # Playback and volume, aimed at the vovo player directly (the built-in
        # media intents need the satellite and player to share an area).
        {
          id = "vovo_controls";
          alias = "vovo - playback and volume";
          mode = "queued";
          triggers = [
            { trigger = "conversation"; command = [ "volume up" "(turn|make) (it|the volume|the music) up" "louder" "(turn|make) it louder" "(increase|raise) [the] volume" "(increase|raise) the music" "a bit louder" ]; id = "up"; }
            { trigger = "conversation"; command = [ "volume down" "(turn|make) (it|the volume|the music) down" "quieter" "softer" "(turn|make) it (quieter|softer)" "(decrease|lower|reduce) [the] volume" "(decrease|lower) the music" "a bit (quieter|softer)" ]; id = "down"; }
            # needs "to" or "percent", so "volume up" can't also match here
            { trigger = "conversation"; command = [ "[set] [the] volume (to|at) {level}" "volume {level} (percent|%)" "(change|put) [the] volume (to|at) {level}" ]; id = "set"; }
            { trigger = "conversation"; command = [ "mute" "mute (it|the music|the sound)" ]; id = "mute"; }
            { trigger = "conversation"; command = [ "unmute" "unmute (it|the music|the sound)" ]; id = "unmute"; }
            { trigger = "conversation"; command = [ "shuffle" "shuffle on" "turn (on shuffle|shuffle on)" "shuffle the music" ]; id = "shuffle_on"; }
            { trigger = "conversation"; command = [ "shuffle off" "turn (off shuffle|shuffle off)" "stop shuffling" ]; id = "shuffle_off"; }
            { trigger = "conversation"; command = [ "repeat (this|the) song" "repeat one" "play this song on repeat" ]; id = "repeat_one"; }
            { trigger = "conversation"; command = [ "repeat" "repeat all" "repeat on" "turn (on repeat|repeat on)" ]; id = "repeat_all"; }
            { trigger = "conversation"; command = [ "repeat off" "turn (off repeat|repeat off)" "stop repeating" ]; id = "repeat_off"; }
            { trigger = "conversation"; command = [ "restart [the] song" "start (over|again)" "play (it|this song) again" "from the (beginning|start)" ]; id = "restart"; }
            { trigger = "conversation"; command = [ "pause" "stop" "pause the music" "stop the music" ]; id = "pause"; }
            { trigger = "conversation"; command = [ "resume" "continue" "unpause" "resume the music" ]; id = "resume"; }
            { trigger = "conversation"; command = [ "next" "next song" "skip" "skip this song" ]; id = "next"; }
            { trigger = "conversation"; command = [ "previous" "previous song" "go back" ]; id = "previous"; }
          ];
          actions = [
            {
              variables = {
                inherit player;
                current = "{{ state_attr('${player}', 'volume_level') | float(0.3) }}";
              };
            }
            {
              choose = [
                {
                  conditions = "{{ trigger.id == 'up' }}";
                  sequence = [
                    { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ [current + 0.1, 1.0] | min | round(2) }}"; }
                    { set_conversation_response = "Volume {{ ([current + 0.1, 1.0] | min * 100) | round(0) | int }} percent."; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'down' }}";
                  sequence = [
                    { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ [current - 0.1, 0.0] | max | round(2) }}"; }
                    { set_conversation_response = "Volume {{ ([current - 0.1, 0.0] | max * 100) | round(0) | int }} percent."; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'set' and (trigger.slots.level | regex_findall('[0-9]+') | count) > 0 }}";
                  sequence = [
                    { variables.level = "{{ [[(trigger.slots.level | regex_findall('[0-9]+') | first | int), 100] | min, 0] | max }}"; }
                    { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ level / 100 }}"; }
                    { set_conversation_response = "Volume {{ level }} percent."; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'pause' }}";
                  sequence = [
                    { action = "media_player.media_pause"; target.entity_id = player; }
                    { set_conversation_response = "Paused."; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'resume' }}";
                  sequence = [
                    { action = "media_player.media_play"; target.entity_id = player; }
                    { set_conversation_response = "Okay."; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'next' }}";
                  sequence = [
                    { action = "media_player.media_next_track"; target.entity_id = player; }
                    { set_conversation_response = "Next song."; }
                  ];
                }
                {
                  conditions = "{{ trigger.id in ['mute', 'unmute'] }}";
                  sequence = [
                    # The player has no mute; remember the volume and use 0.
                    {
                      "if" = [ { condition = "template"; value_template = "{{ trigger.id == 'mute' }}"; } ];
                      "then" = [
                        { action = "input_number.set_value"; target.entity_id = "input_number.vovo_volume_before_mute"; data.value = "{{ [current, 0.05] | max }}"; }
                        { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = 0; }
                        { set_conversation_response = "Muted."; }
                      ];
                      "else" = [
                        { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ states('input_number.vovo_volume_before_mute') | float(0.6) }}"; }
                        { set_conversation_response = "Unmuted."; }
                      ];
                    }
                  ];
                }
                {
                  conditions = "{{ trigger.id in ['shuffle_on', 'shuffle_off'] }}";
                  sequence = [
                    { action = "media_player.shuffle_set"; target.entity_id = player; data.shuffle = "{{ trigger.id == 'shuffle_on' }}"; }
                    { set_conversation_response = "{{ 'Shuffle on.' if trigger.id == 'shuffle_on' else 'Shuffle off.' }}"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id.startswith('repeat_') }}";
                  sequence = [
                    { action = "media_player.repeat_set"; target.entity_id = player; data.repeat = "{{ trigger.id[7:] }}"; }
                    { set_conversation_response = "{{ {'one': 'Repeating this song.', 'all': 'Repeat on.', 'off': 'Repeat off.'}[trigger.id[7:]] }}"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'restart' }}";
                  sequence = [
                    { action = "media_player.media_seek"; target.entity_id = player; data.seek_position = 0; }
                    { set_conversation_response = "From the top."; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'previous' }}";
                  sequence = [
                    { action = "media_player.media_previous_track"; target.entity_id = player; }
                    { set_conversation_response = "Previous song."; }
                  ];
                }
              ];
              default = [ { set_conversation_response = "Say a number, like: volume 40."; } ];
            }
          ];
        }

        # Default music volume: 60% whenever HA starts or the player (re)appears.
        {
          id = "vovo_default_volume";
          alias = "vovo - default volume";
          mode = "restart";
          triggers = [
            { trigger = "homeassistant"; event = "start"; }
            { trigger = "state"; entity_id = player; from = "unavailable"; }
          ];
          actions = [
            { delay.seconds = 10; }
            { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = 0.6; }
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
