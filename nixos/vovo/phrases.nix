# Everything vovo says, in one place. Edit freely, then deploy.
#
# vovo is a cute little panda who talks like a toddler and loves saying
# "oki". It is written "Okee" here so Piper says it right: "Okee" is
# /ˈoʊkiː/ (oh-keeh); "oki" would come out as /ˈoʊki/ with a short ee.
#
# Each message is a list of variants: vovo picks one at random every time.
#
# Placeholders:
#  - Home Assistant replies use templates: {{ name }}, {{ level }}, ... as
#    listed next to each message (the values come from the request). Every
#    variant of a message should keep its placeholders.
#  - YouTube messages and the greeting use {name}-style placeholders.
# Keep the punctuation: it shapes how Piper reads the sentence.
{
  # --- once per boot, when vovo is ready ------------------------------------
  greeting = [
    "You have awakened vovo! Ask me to play some music, and I am sure to find the right song."
    "Yawn! vovo is awake! Okee, music time?"
    "Hello hello! vovo is here!"
    "Okee! Little vovo is ready to play songs!"
    "Hi hi! I had a nice nap. Let's play music!"
    "vovo is awake! Tell me a song, pretty please!"
    "vovo is back! Okee, what do we listen to?"
    "Good nap! Now, music! Okee!"
  ];

  # --- small talk --------------------------------------------------------------
  hello = [
    "Hi hi! Tell me a song!"
    "Hello! vovo wants music!"
    "Hiii! What we play?"
    "Okee! Hello friend!"
    "Hi! Bamboo and songs, yay!"
    "Hello hello! Music time?"
    "Hi! vovo is happy you're here!"
    "Heyyy! Pick a song, okee?"
  ];
  help = [
    "Say play and a song. Or say pause, next, or volume up. Okee!"
    "Tell me: play, and a song name! I can pause, skip, and go louder too."
    "Say play something, and I pick! Or ask: what's playing?"
    "Okee! Say play and a song, or play some lofi, or next!"
    "vovo knows play, pause, next, and volume. Try it!"
    "Say play, and a singer! Or say stop, or volume down."
    "Ask me for a song, a singer, or a mood, like calm. Okee!"
    "I play music! Say play, then what you want. vovo listens!"
  ];
  thanks = [
    "You're welcome!"
    "Okee! Happy vovo!"
    "Hehe, any time!"
    "Yay! vovo loves helping!"
    "Welcome welcome!"
    "vovo hug!"
    "Okee dokee!"
    "My pleasure, friend!"
  ];
  now_playing = [ # {{ title }}, {{ artist }}
    "This is {{ title }} by {{ artist }}."
    "Ooh! {{ title }}, by {{ artist }}!"
    "It's {{ title }}! By {{ artist }}. Okee!"
    "vovo hears {{ title }} by {{ artist }}!"
    "{{ title }}! {{ artist }} sings it!"
    "Now playing {{ title }}, by {{ artist }}. Yay!"
    "This one is {{ title }}, from {{ artist }}!"
    "La la la! {{ title }} by {{ artist }}!"
  ];
  nothing_playing = [
    "Nothing is playing right now."
    "Shh. No music now."
    "vovo hears nothing!"
    "No song playing. Want one?"
    "It's quiet! Okee, pick a song?"
    "Nothing on. vovo is waiting!"
    "No music right now, friend."
    "All quiet! Say play something!"
  ];

  # --- playback and volume ------------------------------------------------------
  volume = [ # {{ level }}: 0-100
    "Volume {{ level }} percent."
    "Okee! Volume {{ level }}!"
    "Now it's {{ level }} percent!"
    "Volume {{ level }}. vovo likes it!"
    "There! {{ level }} percent."
    "Okee, {{ level }} percent!"
    "Volume is {{ level }} now!"
    "{{ level }} percent. Yay!"
  ];
  volume_hint = [
    "Say a number, like: volume 40."
    "How loud? Say volume, and a number!"
    "vovo needs a number! Like volume 50."
    "Tell me a number, okee? Like 30!"
    "Say: volume 60. Like that!"
    "Which number? Volume 40, maybe?"
    "Hmm, say a number, please!"
    "Like this: volume 70. Okee!"
  ];
  paused = [
    "Paused."
    "Okee, pause!"
    "Shh. Paused."
    "vovo pressed pause!"
    "Music stops! Okee."
    "Okee, quiet time."
    "Paused! Nap time?"
    "Shh shh. Pause!"
  ];
  resumed = [
    "Okee!"
    "Music again! Yay!"
    "Okee, playing!"
    "Here we go!"
    "Back to music!"
    "Yay! More music!"
    "Okee dokee, play!"
    "vovo presses play!"
  ];
  muted = [
    "Muted."
    "Shh! Mute!"
    "Okee, no sound."
    "vovo is quiet now."
    "Mute! Shh shh."
    "All quiet! Okee."
    "Sound off!"
    "Shh. Muted!"
  ];
  unmuted = [
    "Unmuted."
    "Sound back! Yay!"
    "Okee, I can sing again!"
    "Music is back!"
    "Sound on!"
    "Okee! Unmute!"
    "vovo can hear again!"
    "Yay, loud again!"
  ];
  shuffle_on = [
    "Shuffle on."
    "Okee, mix mix mix!"
    "Shuffle! Surprise songs!"
    "vovo shakes the songs!"
    "Shuffle on. Wheee!"
    "Okee! Random songs!"
    "Mixing it up!"
    "Surprise mode! Okee!"
  ];
  shuffle_off = [
    "Shuffle off."
    "Okee, in order now."
    "No more shuffle!"
    "Songs in a line now!"
    "Shuffle off. Okee!"
    "One by one now!"
    "Okee, no surprises."
    "Back in order!"
  ];
  repeat_one = [
    "Repeating this song."
    "Again and again! Okee!"
    "This song forever!"
    "vovo loves this one! Repeat!"
    "Okee, one more time, and more!"
    "Repeat this song! Yay!"
    "Same song again! Okee!"
    "Loop loop loop!"
  ];
  repeat_all = [
    "Repeat on."
    "Okee, repeat all!"
    "Round and round!"
    "Repeat on! Yay!"
    "All songs again and again!"
    "Okee, loop everything!"
    "When it ends, start again!"
    "Repeat! Okee!"
  ];
  repeat_off = [
    "Repeat off."
    "Okee, no more repeat."
    "Repeat off! Bye loop!"
    "No more again and again!"
    "Okee, repeat is off."
    "Stop the loop!"
    "Repeat off. Okee!"
    "No repeat now!"
  ];
  seek_forward = [
    "Skipping ahead."
    "Zoom! Forward!"
    "Okee, jump ahead!"
    "Hop hop, forward!"
    "vovo skips a bit!"
    "Forward! Wheee!"
    "Okee, a little ahead!"
    "Jumping forward!"
  ];
  seek_back = [
    "Going back a bit."
    "Back back back!"
    "Okee, a little back!"
    "Rewind! Okee!"
    "vovo goes back a bit!"
    "Hop back!"
    "Again that part! Okee!"
    "Back a little!"
  ];
  queue_cleared = [
    "Queue cleared."
    "All gone! Okee!"
    "Poof! No more songs."
    "Okee, empty list!"
    "vovo cleaned up!"
    "List is empty now!"
    "Bye bye songs!"
    "All clean! Okee!"
  ];
  next_up = [ # {{ title }}, {{ artist }} (may be empty)
    "Next up: {{ title }}{{ ' by ' ~ artist if artist }}."
    "Next is {{ title }}{{ ' by ' ~ artist if artist }}! Yay!"
    "Coming up: {{ title }}{{ ' by ' ~ artist if artist }}!"
    "Okee! Then {{ title }}{{ ' by ' ~ artist if artist }}."
    "After this: {{ title }}{{ ' by ' ~ artist if artist }}!"
    "vovo says next is {{ title }}{{ ' by ' ~ artist if artist }}."
    "Ooh, next: {{ title }}{{ ' by ' ~ artist if artist }}!"
    "Soon: {{ title }}{{ ' by ' ~ artist if artist }}. Okee!"
  ];
  nothing_next = [
    "Nothing is queued after this song."
    "No more songs after this!"
    "This is the last one!"
    "Nothing next! Want more?"
    "Okee, last song!"
    "List is empty after this."
    "No next song, friend!"
    "That's all! Ask for more?"
  ];
  from_the_top = [
    "From the top."
    "Again! From the start!"
    "Okee, start over!"
    "One more time! Yay!"
    "Back to the beginning!"
    "Again again!"
    "Okee, from the top!"
    "vovo starts it again!"
  ];
  previous_song = [
    "Previous song."
    "Back one song!"
    "Okee, the one before!"
    "Going back! Okee!"
    "That song again!"
    "Previous! Yay!"
    "Back back!"
    "Okee, last song again!"
  ];
  next_song = [
    "Next song."
    "Okee, next!"
    "Skip! Next one!"
    "Bye song! Next!"
    "Next! Yay!"
    "Okee dokee, next!"
    "New song coming!"
    "vovo skips!"
  ];
  last_song_finding_similar = [
    "That was the last song, so I'm finding something similar on YouTube. One moment."
    "Last song! vovo looks for more like it. Wait!"
    "No more songs! Okee, I find similar ones!"
    "Out of songs! Looking for more like this!"
    "Okee, finding friends of this song!"
    "vovo searches for more! One moment!"
    "Last one! I'll get more like it. Okee!"
    "Hmm, finding similar songs. Wait wait!"
  ];
  library_pick = [ # {{ title }}
    "Here's something from your library: {{ title }}."
    "Okee! From your songs: {{ title }}!"
    "vovo picked {{ title }}!"
    "Let's play {{ title }}! Yay!"
    "Your song: {{ title }}! Okee!"
    "I found {{ title }} for you!"
    "How about {{ title }}?"
    "Ooh, {{ title }}! Let's go!"
  ];

  # --- "play ..." ---------------------------------------------------------------------
  # {{ verb }} is "Playing", "Added to the queue:" or "Up next:".
  playing_artist = [ # {{ artist }}
    "{{ verb }} music by {{ artist }}."
    "{{ verb }} {{ artist }}! Okee!"
    "{{ verb }} songs by {{ artist }}! Yay!"
    "Okee! {{ verb }} {{ artist }}."
    "{{ verb }} {{ artist }}. vovo likes!"
    "{{ verb }} some {{ artist }}!"
    "{{ verb }} {{ artist }} songs! Wheee!"
    "Ooh! {{ verb }} {{ artist }}!"
  ];
  playing_album = [ # {{ album }}, {{ artist }}
    "{{ verb }} the album {{ album }} by {{ artist }}."
    "{{ verb }} {{ album }}, by {{ artist }}! Okee!"
    "Okee! {{ verb }} {{ album }}, by {{ artist }}!"
    "{{ verb }} {{ album }}! {{ artist }} made it!"
    "{{ verb }} {{ artist }}'s album {{ album }}! Yay!"
    "Ooh! {{ verb }} {{ album }} by {{ artist }}."
    "{{ verb }} the whole {{ album }} album, by {{ artist }}!"
    "{{ verb }} {{ album }} by {{ artist }}. vovo dances!"
  ];
  playing_track = [ # {{ title }}, {{ artist }}
    "{{ verb }} {{ title }} by {{ artist }}."
    "{{ verb }} {{ title }}, by {{ artist }}! Okee!"
    "Okee! {{ verb }} {{ title }}, by {{ artist }}."
    "{{ verb }} {{ title }}! {{ artist }} sings!"
    "Yay! {{ verb }} {{ title }} by {{ artist }}!"
    "{{ verb }} {{ title }} by {{ artist }}. vovo dances!"
    "Ooh! {{ verb }} {{ title }}, from {{ artist }}!"
    "{{ verb }} {{ title }} by {{ artist }}. Wheee!"
  ];
  shuffling_library = [ # {{ title }}
    "Shuffling your library. First up: {{ title }}."
    "Okee! Surprise songs! First: {{ title }}!"
    "Mix mix! Starting with {{ title }}!"
    "vovo picks! First one: {{ title }}!"
    "Random songs! Here's {{ title }}!"
    "Shuffle time! {{ title }} first!"
    "Okee dokee! {{ title }}, then surprises!"
    "Yay, your songs! First: {{ title }}."
  ];
  added_random = [
    "Added some random songs to the queue."
    "Okee! More surprise songs!"
    "I added some songs! Yay!"
    "More songs in the list!"
    "vovo added random songs!"
    "Surprise songs coming! Okee!"
    "Okee, extra songs added!"
    "More music for later!"
  ];
  searching_artist = [ # {{ name }}
    "Let me look for music by {{ name }}. One moment."
    "Okee! Looking for {{ name }}!"
    "vovo searches {{ name }}! Wait wait!"
    "Hmm, {{ name }}? I'll find it!"
    "Finding {{ name }} songs! One moment!"
    "Okee, getting {{ name }}! Wait a bit!"
    "Sniff sniff, looking for {{ name }}!"
    "Searching {{ name }}! Okee!"
  ];
  searching_album = [ # {{ title }}
    "Let me look for the album {{ title }}. One moment."
    "Okee! Looking for {{ title }}!"
    "vovo searches the album {{ title }}!"
    "Finding {{ title }}! Wait wait!"
    "Hmm, the album {{ title }}? One moment!"
    "Okee, getting {{ title }}!"
    "Sniff sniff, {{ title }}!"
    "Searching for {{ title }}! Okee!"
  ];
  searching_song = [ # {{ title }}
    "Let me look for {{ title }}. One moment."
    "Okee! Looking for {{ title }}!"
    "vovo searches {{ title }}! Wait!"
    "Finding {{ title }}! One moment!"
    "Hmm, {{ title }}? I'll get it!"
    "Okee, getting {{ title }}!"
    "Sniff sniff, {{ title }}!"
    "Searching {{ title }}! Okee!"
  ];
  playing_mood = [ # {{ name }}: the mood
    "Playing some {{ name }}. One moment."
    "Okee! Some {{ name }} music!"
    "Ooh, {{ name }}! Coming up!"
    "{{ name }} time! Wait a bit!"
    "vovo loves {{ name }}! One moment!"
    "Okee, {{ name }} songs! Yay!"
    "Getting some {{ name }}! Okee!"
    "{{ name }}? Yes yes! One moment!"
  ];
  getting_playlist = [ # {{ name }}
    "Getting the playlist {{ name }} from YouTube. One moment."
    "Okee! Getting the {{ name }} playlist!"
    "vovo fetches {{ name }}! Wait!"
    "Finding the playlist {{ name }}!"
    "Okee, {{ name }} playlist! One moment!"
    "Getting {{ name }}! Wait wait!"
    "Sniff sniff, playlist {{ name }}!"
    "Okee dokee, {{ name }} coming!"
  ];
  getting_genre = [ # {{ name }}
    "Getting a {{ name }} playlist from YouTube. One moment."
    "Okee! Some {{ name }} music!"
    "vovo finds {{ name }} songs! Wait!"
    "{{ name }} music? Coming up!"
    "Okee, getting {{ name }}! One moment!"
    "Ooh, {{ name }}! Wait a bit!"
    "Finding {{ name }} songs! Okee!"
    "Yay, {{ name }}! One moment!"
  ];
  playing_yt_playlist = [ # {{ name }}: what you asked for
    "Playing a {{ name }} playlist. One moment."
    "Okee! A {{ name }} playlist!"
    "vovo gets the {{ name }} playlist! Wait!"
    "{{ name }} playlist! Coming up!"
    "Ooh, {{ name }} songs! One moment!"
    "Okee dokee! {{ name }} playlist!"
    "Finding a {{ name }} playlist! Okee!"
    "Yay, {{ name }}! Wait a bit!"
  ];
  unknown_name = [ # {{ name }}
    "I heard {{ name }}, but I don't know that one. Say: play {{ name }} from YouTube, to search for it anyway."
    "Hmm, {{ name }}? vovo doesn't know it. Say: play {{ name }} from YouTube!"
    "I heard {{ name }}. Don't know it! Say: play {{ name }} from YouTube."
    "Uh oh! {{ name }}? Say: play {{ name }} from YouTube, okee?"
    "vovo is confused! {{ name }}? Try: play {{ name }} from YouTube."
    "{{ name }}? Hmm. Say it again, or: play {{ name }} from YouTube."
    "I don't know {{ name }}. Say: play {{ name }} from YouTube!"
    "Oops! {{ name }}? Say: play {{ name }} from YouTube, and I'll look!"
  ];

  # --- YouTube fetcher (Python placeholders) -------------------------------------
  youtube_library_instead = [ # {label}
    "Playing {label}, from your library."
    "Okee! {label}, from your songs!"
    "Found it at home! {label}!"
    "vovo found {label} in your songs!"
    "{label}! It was here all along!"
    "Okee, your own {label}!"
    "Yay, {label}, from your library!"
    "No need to search! {label}!"
  ];
  youtube_not_found = [ # {query}
    "Sorry, I couldn't find {query} on YouTube."
    "Uh oh! No {query} on YouTube."
    "vovo looked and looked. No {query}!"
    "Sorry! {query} is hiding!"
    "Hmm, no {query}. Try again?"
    "Oops! Can't find {query}."
    "Sorry sorry! No {query}!"
    "{query}? vovo found nothing!"
  ];
  youtube_failed = [ # {query}
    "Sorry, I couldn't get {query} from YouTube."
    "Uh oh! {query} didn't work."
    "Oops! vovo couldn't get {query}."
    "Sorry! {query} got stuck."
    "Hmm, {query} won't come. Try again?"
    "Oh no! No {query} today."
    "Sorry sorry! {query} failed."
    "vovo tried! {query} didn't come."
  ];
  youtube_mood_failed = [ # {mood}
    "Sorry, I couldn't get {mood} songs from YouTube."
    "Uh oh! No {mood} songs now."
    "Oops! {mood} songs didn't come."
    "Sorry! vovo couldn't get {mood}."
    "Hmm, {mood} is stuck. Try again?"
    "Oh no! No {mood} today."
    "Sorry sorry! {mood} failed."
    "vovo tried! No {mood} songs."
  ];
  youtube_mood_playlist_failed = [ # {mood}
    "Sorry, I couldn't get the {mood} playlist from YouTube."
    "Uh oh! The {mood} playlist didn't come."
    "Oops! No {mood} playlist now."
    "Sorry! vovo couldn't get {mood}."
    "Hmm, the {mood} list is stuck."
    "Oh no! No {mood} playlist today."
    "Sorry sorry! {mood} failed."
    "vovo tried! No {mood} list."
  ];
  more_like_this = [ # {artist}
    "Here is more music like {artist}."
    "Okee! More like {artist}!"
    "Songs ended! More {artist} vibes!"
    "vovo found more like {artist}!"
    "Yay! More music like {artist}!"
    "Okee dokee! Keep going with {artist}!"
    "More, more! Like {artist}!"
    "Music keeps going! Like {artist}!"
  ];
}
