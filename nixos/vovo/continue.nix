# When the queue runs out, keep the music going in the same style.
#
# The player goes "idle" only when the queue has played to the end (or was
# cleared); "stop"/"pause" by voice leave it "paused", so they never trigger
# this. youtube-fetch (kind "continue") then looks at what was playing:
#  - after a mood ("play some lofi"): more of that mood;
#  - otherwise: the last songs' artists and genres plus YouTube Music's
#    related songs ("radio") for them; library songs by those artists start
#    at once, new related songs from YouTube are queued as they download.
# Only while someone asked for music in the last 8 hours: a forgotten radio
# does not play all night.
{ player }:
{
  id = "vovo_continue_music";
  alias = "vovo - continue when the queue ends";
  mode = "single";
  triggers = [
    { trigger = "state"; entity_id = player; from = "playing"; to = "idle"; for.seconds = 15; }
  ];
  conditions = [
    {
      condition = "template";
      value_template = "{{ now().timestamp() - (state_attr('input_datetime.vovo_last_request_at', 'timestamp') | float(0)) < 8 * 3600 }}";
    }
    { condition = "state"; entity_id = "assist_satellite.vovo"; state = "idle"; }
  ];
  actions = [
    {
      action = "shell_command.youtube_fetch";
      data = {
        kind = "continue";
        query = "{{ states('input_text.vovo_last_request') if states('input_text.vovo_last_request') not in ['', 'unknown', 'unavailable'] else 'plain|' }}";
        option = "replace";
      };
    }
  ];
}
