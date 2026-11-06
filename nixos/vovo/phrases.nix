# Everything vovo says, in one place. Edit freely, then deploy.
#
# Each message is a list of variants: vovo picks one at random every time
# (a list with one entry always says the same thing).
#
# Placeholders:
#  - Home Assistant replies use templates: {{ name }}, {{ level }}, ... as
#    listed next to each message (the values come from the request).
#  - YouTube messages and the greeting use {name}-style placeholders.
# Keep the punctuation: it shapes how Piper reads the sentence.
{
  # --- once per boot, when vovo is ready ------------------------------------
  greeting = [
    "You have awakened vovo! Ask me to play some music, and I am sure to find the right song."
    "vovo is awake! Tell me what to play, and I will do my best."
    "Hello, I am vovo, and I am ready to play some music."
  ];

  # --- small talk --------------------------------------------------------------
  hello = [ "Hi! Tell me a song and I'll play it." "Hello! What should we listen to?" "Hey there! Ready for some music?" ];
  help = [ "Say play and a song name, or play something for a random song. You can also ask what's playing, or say pause, next, or volume up." ];
  thanks = [ "You're welcome!" "Any time!" "My pleasure!" ];
  now_playing = [ "This is {{ title }} by {{ artist }}." ]; # {{ title }}, {{ artist }}
  nothing_playing = [ "Nothing is playing right now." ];

  # --- playback and volume ------------------------------------------------------
  volume = [ "Volume {{ level }} percent." ]; # {{ level }}: 0-100
  volume_hint = [ "Say a number, like: volume 40." ];
  paused = [ "Paused." "Okay, pausing." "Shh. Paused." ];
  resumed = [ "Okay." ];
  muted = [ "Muted." ];
  unmuted = [ "Unmuted." ];
  shuffle_on = [ "Shuffle on." ];
  shuffle_off = [ "Shuffle off." ];
  repeat_one = [ "Repeating this song." ];
  repeat_all = [ "Repeat on." ];
  repeat_off = [ "Repeat off." ];
  seek_forward = [ "Skipping ahead." ];
  seek_back = [ "Going back a bit." ];
  queue_cleared = [ "Queue cleared." ];
  next_up = [ "Next up: {{ title }}{{ ' by ' ~ artist if artist }}." ]; # {{ title }}, {{ artist }} (may be empty)
  nothing_next = [ "Nothing is queued after this song." ];
  from_the_top = [ "From the top." ];
  previous_song = [ "Previous song." ];
  next_song = [ "Next song." ];
  last_song_finding_similar = [ "That was the last song, so I'm finding something similar on YouTube. One moment." ];
  library_pick = [ "Here's something from your library: {{ title }}." ]; # {{ title }}

  # --- "play ..." ---------------------------------------------------------------------
  # {{ verb }} is "Playing", "Added to the queue:" or "Up next:".
  playing_artist = [ "{{ verb }} music by {{ artist }}." ]; # {{ artist }}
  playing_album = [ "{{ verb }} the album {{ album }} by {{ artist }}." ]; # {{ album }}, {{ artist }}
  playing_track = [ "{{ verb }} {{ title }} by {{ artist }}." ]; # {{ title }}, {{ artist }}
  shuffling_library = [ "Shuffling your library. First up: {{ title }}." ]; # {{ title }}
  added_random = [ "Added some random songs to the queue." ];
  searching_artist = [ "Let me look for music by {{ name }}. One moment." ]; # {{ name }}
  searching_album = [ "Let me look for the album {{ title }}. One moment." ]; # {{ title }}
  searching_song = [ "Let me look for {{ title }}. One moment." ]; # {{ title }}
  playing_mood = [ "Playing some {{ name }}. One moment." ]; # {{ name }}: the mood
  getting_playlist = [ "Getting the playlist {{ name }} from YouTube. One moment." ]; # {{ name }}
  getting_genre = [ "Getting a {{ name }} playlist from YouTube. One moment." ]; # {{ name }}
  playing_yt_playlist = [ "Playing a {{ name }} playlist. One moment." ]; # {{ name }}: what you asked for
  unknown_name = [ "I heard {{ name }}, but I don't know that one. Say: play {{ name }} from YouTube, to search for it anyway." ]; # {{ name }}

  # --- YouTube fetcher (Python placeholders) -------------------------------------
  youtube_library_instead = [ "Playing {label}, from your library." ]; # {label}
  youtube_not_found = [ "Sorry, I couldn't find {query} on YouTube." ]; # {query}
  youtube_failed = [ "Sorry, I couldn't get {query} from YouTube." ]; # {query}
  youtube_mood_failed = [ "Sorry, I couldn't get {mood} songs from YouTube." ]; # {mood}
  youtube_mood_playlist_failed = [ "Sorry, I couldn't get the {mood} playlist from YouTube." ]; # {mood}
  more_like_this = [ "Here is more music like {artist}." "Keeping the music going with more like {artist}." ]; # {artist}
}
