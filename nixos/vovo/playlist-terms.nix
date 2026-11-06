# Search terms for "play (some) X playlist".
#
#  terms:  when the speech-to-text gets one slightly wrong ("animate" for
#          "anime"), vovo-names snaps it back; anything that is not a near
#          miss of one of these is searched as heard. Add what you ask for.
#  heard:  mishearings too far off to be caught as near misses, mapped to
#          what was meant. Find new ones in the log: `journalctl -u
#          wyoming-faster-whisper-vovo | grep dispatch_handler`.
{
  heard = {
    "mod fi" = "lofi"; # "play the lofi playlist" -> "the mod-fi playlist" (2026-11-06)
    "animal" = "anime";
    "animate" = "anime";
    "onions" = "anime";
    "onion" = "anime";
  };
  terms = [
  "anime" "anime openings" "anime endings" "anime ost" "anime lofi"
  "jujutsu kaisen" "demon slayer" "attack on titan" "naruto" "one piece"
  "dragon ball" "pokemon" "studio ghibli" "my hero academia" "chainsaw man"
  "k-pop" "j-pop" "lofi" "jazz" "classical" "piano" "rock" "classic rock"
  "pop" "hip hop" "rap" "metal" "punk" "blues" "reggae" "country" "disco"
  "funk" "soul" "r&b" "house" "techno" "edm" "bossa nova" "samba" "latin"
  "workout" "gym" "running" "study" "sleep" "chill" "relaxing" "party"
  "summer" "christmas" "halloween" "road trip" "gaming" "video game music"
  "movie soundtracks" "disney" "80s" "90s" "2000s" "love songs" "acoustic"
];
}
