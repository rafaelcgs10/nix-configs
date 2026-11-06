# vovo-voice-hooks <event>: wyoming-satellite event hooks (voice.nix).
#
#   detect      wake word heard: mute the music at once (PipeWire, ~30 ms),
#               then pause it in Music Assistant in the background
#   transcript  command recognised (text on stdin), ~0.5 s after the second
#               beep: resume and unmute, unless the command was pause/stop
#   error       nothing recognised: resume
#   tts-start   vovo starts speaking: duck the music to 30 % of its volume
#   tts-played  vovo finished speaking: volume back (unless someone changed
#               it meanwhile); resume if a pause is somehow still pending
#
# Music Assistant's pause takes ~1 s and could overtake a quick resume, so
# the instant part is the mute, and a resume always waits for the pause.
set -u
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" # pactl -> rafael's PipeWire
state="$XDG_RUNTIME_DIR/vovo-voice"
mkdir -p "$state"
tok=$(cat /var/lib/vovo/ma-token)

ma() { # ma <command> [json args]
  curl -sf -m 4 -X POST -H "Authorization: Bearer $tok" -H "Content-Type: application/json" \
    http://127.0.0.1:8095/api -d "{\"message_id\":\"1\",\"command\":\"$1\",\"args\":${2:-{\}}}"
}
player() {
  if [ ! -s "$state/player" ]; then
    ma players/all | jq -r '.[] | select(.display_name == "vovo") | .player_id' > "$state/player"
  fi
  cat "$state/player"
}
input() { # SqueezeLite's PipeWire stream (absent while squeezelite has no output open)
  pactl -f json list sink-inputs 2>/dev/null |
    jq -r '.[] | select(.properties["application.name"] == "SqueezeLite") | .index' | head -1
}
volume() { # current volume of a stream, in percent
  pactl -f json list sink-inputs | jq -r ".[] | select(.index == $1) | .volume | to_entries[0].value.value_percent" | tr -d '%'
}
mute() { local i; i=$(input); [ -n "$i" ] && pactl set-sink-input-mute "$i" "$1"; }
wait_pause() { # until the background pause from "detect" has finished
  local n=0
  while [ -e "$state/pausing" ] && [ $n -lt 50 ]; do sleep 0.1; n=$((n + 1)); done
}
resume() {
  wait_pause
  if [ -e "$state/paused" ]; then
    rm -f "$state/paused"
    ma players/cmd/play "{\"player_id\":\"$(player)\"}" >/dev/null
  fi
  mute 0
}

# What counts as "stop the music" (keep in step with the pause command in
# home-assistant.nix): then the music stays paused.
STOP='^(please )?(pause|stop|quiet|silence|shut up|be quiet|enough|no more music|music off|(that.?s|that is) enough|(turn|switch) (it |the music )?off|(turn|switch) off( the)? music|(cut|kill|end) the music)'

case "${1:-}" in
  detect)
    rm -f "$state/paused" "$state/ducked"
    mute 1
    touch "$state/pausing"
    ( if [ "$(ma players/get "{\"player_id\":\"$(player)\"}" | jq -r .playback_state)" = playing ]; then
        touch "$state/paused"
        ma players/cmd/pause "{\"player_id\":\"$(player)\"}" >/dev/null
      fi
      rm -f "$state/pausing" ) </dev/null >/dev/null 2>&1 &
    ;;
  transcript)
    text=$(tr '[:upper:]' '[:lower:]' | sed 's/[.!?,]//g; s/^ *//')
    if printf '%s' "$text" | grep -qE "$STOP"; then
      wait_pause
      rm -f "$state/paused" # stays paused; HA's pause command does the rest
      ( sleep 3; mute 0 ) </dev/null >/dev/null 2>&1 &
    else
      resume
    fi
    ;;
  error) resume ;;
  tts-start)
    i=$(input)
    if [ -n "$i" ]; then
      v=$(volume "$i")
      d=$(( v * 30 / 100 ))
      echo "$i $v $d" > "$state/ducked"
      pactl set-sink-input-volume "$i" "$d%"
    fi
    ;;
  tts-played)
    if [ -s "$state/ducked" ]; then
      read -r i v d < "$state/ducked"
      rm -f "$state/ducked"
      # restore only if nobody changed the volume while vovo was talking
      [ "$(volume "$i" 2>/dev/null)" = "$d" ] && pactl set-sink-input-volume "$i" "$v%"
    fi
    resume
    ;;
esac
exit 0
