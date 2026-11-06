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
  # Everything vovo says comes from phrases.nix (random variants).
  p = (import ./say.nix).pick;
in
{
  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraComponents = [
      # The onboarding wizard's defaults (met, radio_browser, shopping_list,
      # google_translate) were removed 2026-11-06: nothing here uses them.
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

      # Set while the music is paused for a voice command; cleared by a
      # pause/stop command so the music then stays paused.
      input_boolean.vovo_resume_after_voice = {
        name = "vovo resume after voice command";
        initial = false;
      };

      # The last "play ..." request ("mood|lofi", "artist|Daft Punk") and when
      # it was made: used to continue the music when the queue runs out
      # (continue.nix).
      input_text.vovo_last_request = {
        name = "vovo last play request";
        max = 255;
      };
      input_datetime.vovo_last_request_at = {
        name = "vovo last play request at";
        has_date = true;
        has_time = true;
      };

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
        # "play ...": see ha-play.nix
        (import ./ha-play.nix { inherit player; })
        # queue ran out: more of the same (see continue.nix)
        (import ./continue.nix { inherit player; })

        # Playback and volume, aimed at the vovo player directly (the built-in
        # media intents need the satellite and player to share an area).
        {
          id = "vovo_controls";
          alias = "vovo - playback and volume";
          mode = "queued";
          triggers = [
            { trigger = "conversation"; command = [ "volume up" "(turn|make) (it|the volume|the music) up" "louder" "(turn|make) it louder" "(increase|raise) [the] volume" "(increase|raise) the music" "a bit louder" ]; id = "up"; }
            { trigger = "conversation"; command = [ "much louder" "(a lot|way) louder" "turn it up a lot" ]; id = "up_lot"; }
            { trigger = "conversation"; command = [ "much (quieter|softer)" "(a lot|way) (quieter|softer)" "turn it down a lot" ]; id = "down_lot"; }
            { trigger = "conversation"; command = [ "(max|maximum|full) volume" "[set] [the] volume to (max|maximum|full)" ]; id = "max"; }
            { trigger = "conversation"; command = [ "(min|minimum|lowest) volume" "[set] [the] volume to (min|minimum|the lowest)" ]; id = "min"; }
            { trigger = "conversation"; command = [ "volume down" "(turn|make) (it|the volume|the music) down" "quieter" "softer" "(turn|make) it (quieter|softer)" "(decrease|lower|reduce) [the] volume" "(decrease|lower) the music" "a bit (quieter|softer)" ]; id = "down"; }
            # needs "to" or "percent", so "volume up" can't also match here
            { trigger = "conversation"; command = [ "[set] [the] volume (to|at) {level}" "volume {level} (percent|%)" "(change|put) [the] volume (to|at) {level}" ]; id = "set"; }
            { trigger = "conversation"; command = [ "mute" "mute (it|the music|the sound)" ]; id = "mute"; }
            { trigger = "conversation"; command = [ "unmute" "unmute (it|the music|the sound)" ]; id = "unmute"; }
            { trigger = "conversation"; command = [ "shuffle" "shuffle on" "turn (on shuffle|shuffle on)" "shuffle the music" ]; id = "shuffle_on"; }
            { trigger = "conversation"; command = [ "shuffle off" "turn (off shuffle|shuffle off)" "stop shuffling" ]; id = "shuffle_off"; }
            { trigger = "conversation"; command = [ "repeat (this|the) song" "repeat one" "put this song on repeat" ]; id = "repeat_one"; }
            { trigger = "conversation"; command = [ "repeat" "repeat all" "repeat on" "turn (on repeat|repeat on)" ]; id = "repeat_all"; }
            { trigger = "conversation"; command = [ "repeat off" "turn (off repeat|repeat off)" "stop repeating" ]; id = "repeat_off"; }
            { trigger = "conversation"; command = [ "restart [the] song" "start (over|again)" "from the (beginning|start)" "replay" "replay (it|this|the song|this song)" "one more time" ]; id = "restart"; }
            { trigger = "conversation"; command = [ "skip ahead" "fast forward" "jump ahead" "forward [30] [seconds]" ]; id = "seek_fwd"; }
            { trigger = "conversation"; command = [ "rewind" "go back a bit" "back [15] seconds" ]; id = "seek_back"; }
            { trigger = "conversation"; command = [ "clear the (queue|playlist)" "empty the queue" ]; id = "clear"; }
            { trigger = "conversation"; command = [ "what's next" "what is next" "what's the next song" "what song is next" "what comes next" ]; id = "whats_next"; }
            { trigger = "conversation"; command = [
                "pause" "pause [the] (music|song)" "pause it"
                "stop" "stop [the] (music|song)" "stop (it|this|that)" "stop playing" "stop the music please" "please stop [the music]"
                "turn (it|the music) off" "turn off [the] music" "switch (it|the music) off" "switch off [the] music" "music off"
                "(that's|that is) enough" "enough [music]" "no more music" "(cut|kill|end) the music"
                "be quiet" "quiet" "silence" "shut up"
              ]; id = "pause"; }
            { trigger = "conversation"; command = [ "resume" "continue" "unpause" "resume the music" "play" "keep playing" "continue playing" "resume playing" "start the music" "turn (on the music|the music on)" "music on" "go on" ]; id = "resume"; }
            { trigger = "conversation"; command = [ "next" "next song" "next (one|track)" "skip" "skip (it|this|this one|this song|this track)" "(go|skip) to the next (song|track)" "change the song" "another song" "I don't like this song" ]; id = "next"; }
            { trigger = "conversation"; command = [ "previous" "previous song" "previous (one|track)" "go back" "go back a song" "[go] [back] to the previous (song|track)" "last song" ]; id = "previous"; }
          ];
          actions = [
            {
              variables = {
                inherit player;
                current = "{{ state_attr('${player}', 'volume_level') | float(0.3) }}";
                # "set the volume to 40" or, as the speech-to-text writes it,
                # "... to forty percent": the level as a number, or "" if none.
                level_num = ''
                  {%- set w = (trigger.slots.level | default("")) | lower | replace('-', ' ') -%}
                  {%- set d = w | regex_findall('[0-9]+') -%}
                  {%- if d -%}{{ d | first }}{%- else -%}
                  {%- set units = {'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10, 'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15, 'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19, 'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50, 'sixty': 60, 'seventy': 70, 'eighty': 80, 'ninety': 90} -%}
                  {%- set ns = namespace(n=0, found=false) -%}
                  {%- for t in w.split() -%}
                    {%- if t in units -%}{%- set ns.n = ns.n + units[t] -%}{%- set ns.found = true -%}
                    {%- elif t == 'hundred' -%}{%- set ns.n = [ns.n, 1] | max * 100 -%}{%- set ns.found = true -%}
                    {%- endif -%}
                  {%- endfor -%}
                  {{ ns.n if ns.found else "" }}
                  {%- endif -%}
                '';
              };
            }
            {
              choose = [
                {
                  conditions = "{{ trigger.id == 'up' }}";
                  sequence = [
                    { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ [current + 0.1, 1.0] | min | round(2) }}"; }
                    { set_conversation_response = "{% set level = ([current + 0.1, 1.0] | min * 100) | round(0) | int %}${p "volume"}"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'down' }}";
                  sequence = [
                    { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ [current - 0.1, 0.0] | max | round(2) }}"; }
                    { set_conversation_response = "{% set level = ([current - 0.1, 0.0] | max * 100) | round(0) | int %}${p "volume"}"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'set' and level_num | string | length > 0 }}";
                  sequence = [
                    { variables.level = "{{ [[level_num | int, 100] | min, 0] | max }}"; }
                    { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ level / 100 }}"; }
                    { set_conversation_response = p "volume"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'pause' }}";
                  sequence = [
                    { action = "input_boolean.turn_off"; target.entity_id = "input_boolean.vovo_resume_after_voice"; }
                    { action = "media_player.media_pause"; target.entity_id = player; }
                    { set_conversation_response = p "paused"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'resume' }}";
                  sequence = [
                    { action = "media_player.media_play"; target.entity_id = player; }
                    { set_conversation_response = p "resumed"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'next' }}";
                  sequence = import ./ha-next.nix { inherit player; };
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
                        { set_conversation_response = p "muted"; }
                      ];
                      "else" = [
                        { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ states('input_number.vovo_volume_before_mute') | float(0.6) }}"; }
                        { set_conversation_response = p "unmuted"; }
                      ];
                    }
                  ];
                }
                {
                  conditions = "{{ trigger.id in ['shuffle_on', 'shuffle_off'] }}";
                  sequence = [
                    { action = "media_player.shuffle_set"; target.entity_id = player; data.shuffle = "{{ trigger.id == 'shuffle_on' }}"; }
                    { set_conversation_response = "{% if trigger.id == 'shuffle_on' %}${p "shuffle_on"}{% else %}${p "shuffle_off"}{% endif %}"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id.startswith('repeat_') }}";
                  sequence = [
                    { action = "media_player.repeat_set"; target.entity_id = player; data.repeat = "{{ trigger.id[7:] }}"; }
                    { set_conversation_response = "{% set r = trigger.id[7:] %}{% if r == 'one' %}${p "repeat_one"}{% elif r == 'all' %}${p "repeat_all"}{% else %}${p "repeat_off"}{% endif %}"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id in ['up_lot', 'down_lot', 'max', 'min'] }}";
                  sequence = [
                    { variables.target = "{{ {'up_lot': [current + 0.2, 1.0] | min, 'down_lot': [current - 0.2, 0.05] | max, 'max': 1.0, 'min': 0.1}[trigger.id] | round(2) }}"; }
                    { action = "media_player.volume_set"; target.entity_id = player; data.volume_level = "{{ target }}"; }
                    { set_conversation_response = "{% set level = (target * 100) | round(0) | int %}${p "volume"}"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id in ['seek_fwd', 'seek_back'] }}";
                  sequence = [
                    {
                      variables.pos = "{% set p = state_attr(player, 'media_position') | float(0) %}{% set u = state_attr(player, 'media_position_updated_at') %}{{ p + ((now() - u).total_seconds() if u and is_state(player, 'playing') else 0) }}";
                    }
                    { action = "media_player.media_seek"; target.entity_id = player; data.seek_position = "{{ [pos + (30 if trigger.id == 'seek_fwd' else -15), 0] | max | int }}"; }
                    { set_conversation_response = "{% if trigger.id == 'seek_fwd' %}${p "seek_forward"}{% else %}${p "seek_back"}{% endif %}"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'clear' }}";
                  sequence = [
                    { action = "media_player.clear_playlist"; target.entity_id = player; }
                    { set_conversation_response = p "queue_cleared"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'whats_next' }}";
                  sequence = [
                    { action = "music_assistant.get_queue"; target.entity_id = player; response_variable = "q"; }
                    {
                      set_conversation_response = "{% set n = q[player].next_item if q and player in q else none %}{% if n and n.media_item %}{% set title = n.media_item.name %}{% set artist = n.media_item.artists | map(attribute='name') | join(' and ') %}${p "next_up"}{% elif n %}{% set title = n.name %}{% set artist = '' %}${p "next_up"}{% else %}${p "nothing_next"}{% endif %}";
                    }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'restart' }}";
                  sequence = [
                    { action = "media_player.media_seek"; target.entity_id = player; data.seek_position = 0; }
                    { set_conversation_response = p "from_the_top"; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'previous' }}";
                  sequence = [
                    { action = "media_player.media_previous_track"; target.entity_id = player; }
                    { set_conversation_response = p "previous_song"; }
                  ];
                }
              ];
              default = [ { set_conversation_response = p "volume_hint"; } ];
            }
          ];
        }

        # Pause the music while vovo listens ("hey/oki vovo"), resume it when
        # the command is done (after the spoken reply), unless the command was
        # pause/stop (that clears the flag).
        {
          id = "vovo_pause_for_voice";
          alias = "vovo - pause music while listening";
          mode = "queued";
          triggers = [
            { trigger = "state"; entity_id = "assist_satellite.vovo"; to = "listening"; id = "listening"; }
            { trigger = "state"; entity_id = "assist_satellite.vovo"; to = "idle"; id = "idle"; }
          ];
          actions = [
            {
              choose = [
                {
                  conditions = "{{ trigger.id == 'listening' and is_state('${player}', 'playing') }}";
                  sequence = [
                    { action = "input_boolean.turn_on"; target.entity_id = "input_boolean.vovo_resume_after_voice"; }
                    { action = "media_player.media_pause"; target.entity_id = player; }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'idle' and is_state('input_boolean.vovo_resume_after_voice', 'on') }}";
                  sequence = [
                    { action = "input_boolean.turn_off"; target.entity_id = "input_boolean.vovo_resume_after_voice"; }
                    # Only resume what we paused; "play X" is already playing.
                    {
                      "if" = [ { condition = "state"; entity_id = player; state = "paused"; } ];
                      "then" = [ { action = "media_player.media_play"; target.entity_id = player; } ];
                    }
                  ];
                }
              ];
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
                  sequence = [ { set_conversation_response = p "hello"; } ];
                }
                {
                  conditions = "{{ trigger.id == 'help' }}";
                  sequence = [
                    {
                      set_conversation_response = p "help";
                    }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'now_playing' }}";
                  sequence = [
                    {
                      set_conversation_response = "{% if is_state(player, 'playing') %}{% set title = state_attr(player, 'media_title') %}{% set artist = state_attr(player, 'media_artist') %}${p "now_playing"}{% else %}${p "nothing_playing"}{% endif %}";
                    }
                  ];
                }
                {
                  conditions = "{{ trigger.id == 'thanks' }}";
                  sequence = [ { set_conversation_response = p "thanks"; } ];
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

  systemd.services.home-assistant.serviceConfig = {
    MemoryHigh = "450M";
    # Voice commands wait on HA (intent + automations): keep it responsive
    # and mostly in RAM rather than swap.
    CPUWeight = 500;
    MemoryLow = "350M";
  };
}
