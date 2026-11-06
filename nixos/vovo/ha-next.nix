# "Next song" for vovo, shared by the "next" command and "play next" (a list
# of Home Assistant actions).
#
# - something queued after the current song: skip to it;
# - queue empty (e.g. a single YouTube song): play songs related to the
#   current one from YouTube Music's radio (youtube.nix, kind "related");
# - nothing playing at all: shuffle the library.
{ player }:

let
  p = (import ./say.nix).pick; # texts: phrases.nix
in
[
  {
    action = "music_assistant.get_queue";
    target.entity_id = player;
    response_variable = "q";
  }
  {
    variables = {
      has_next = "{{ q is defined and q[player] is defined and q[player].next_item is not none }}";
      now_title = "{{ state_attr(player, 'media_title') or '' }}";
      now_artist = "{{ state_attr(player, 'media_artist') or '' }}";
    };
  }
  {
    choose = [
      {
        conditions = "{{ has_next }}";
        sequence = [
          { action = "media_player.media_next_track"; target.entity_id = player; }
          { set_conversation_response = p "next_song"; }
        ];
      }
      {
        conditions = "{{ now_title != '' }}";
        sequence = [
          {
            action = "shell_command.youtube_fetch";
            data = { kind = "related"; option = "replace"; query = "{{ now_title }} {{ now_artist }}"; };
          }
          { set_conversation_response = p "last_song_finding_similar"; }
        ];
      }
    ];
    default = [
      {
        action = "music_assistant.get_library";
        data = { config_entry_id = "{{ config_entry_id('${player}') }}"; media_type = "track"; order_by = "random"; limit = 25; };
        response_variable = "lib";
      }
      {
        action = "music_assistant.play_media";
        target.entity_id = player;
        data = { media_id = "{{ lib['items'] | map(attribute='uri') | list }}"; media_type = "track"; enqueue = "replace"; };
      }
      { set_conversation_response = "{% set title = lib['items'][0].name %}${p "library_pick"}"; }
    ];
  }
]
