# Moods for "play some <mood>": hand-picked YouTube playlists.
#
# names.nix recognises the words (also when misheard: "low fy", "lo-fi"), and
# youtube-fetch plays a mix: up to 5 songs by the mood's artists that are
# already in the library (instant start, works without YouTube), then random
# songs from the playlists (it lists at most the first 1000 entries of each
# and caches that list for a week). Moods not listed here ("play some jazz
# music") fall back to a YouTube Music playlist search that skips hour-long
# mixes and off-topic playlists.
#
# To add a mood: a few words people say for it, typical artists, and
# playlists of single songs (not 1-hour mixes; any youtube.com or
# music.youtube.com playlist URL). The name is what vovo says ("Playing some
# romantic piano"). Playlists checked 2026-11-06: track count, median length.
{
  lofi = {
    words = [ "lofi" "lo fi" "lofi girl" "lofi hip hop" "lofi beats" "chill beats" "chillhop" "study music" "study beats" "beats to study to" ];
    artists = [ "Lofi Girl" "Nujabes" "Idealism" "Jinsang" "Tomppabeats" ];
    playlists = [
      # Lofi Girl, "lofi hip hop playlist - beats to relax/study to" (4,749, 2.5 min)
      "https://www.youtube.com/playlist?list=PLHD44KRu8Ods"
    ];
  };

  "romantic piano" = {
    words = [ "romantic piano" "piano" "piano music" "piano love songs" "soft piano" "relaxing piano" ];
    artists = [ "Yiruma" "Ludovico Einaudi" "Frédéric Chopin" "Richard Clayderman" "Max Richter" ];
    playlists = [
      # "Top Piano Music - Best Pianist Composer: Yiruma, ..." (89, 3.5 min)
      "https://www.youtube.com/playlist?list=PLmS86t_jmQvZQEG1U813_W-AOI6icWb1M"
      # "Best Of Love Songs Piano Instrumental" (93, 4.3 min)
      "https://www.youtube.com/playlist?list=PLz9f2B96GIdIi2piK-LrT94SaucZUCtzQ"
      # "Best of Piano Music (neoclassical): Einaudi, Richter, ..." (41, 4.9 min)
      "https://www.youtube.com/playlist?list=PLqCJMB22vIQXI0TlNmVQh8AbtslC3kokA"
    ];
  };

  romantic = {
    words = [ "romantic" "romantic music" "romantic songs" "love songs" "romance" "date night" ];
    artists = [ "Ed Sheeran" "Adele" "John Legend" "Whitney Houston" "Ella Fitzgerald" "Norah Jones" ];
    playlists = [
      # "500 Greatest Love Songs Of All Time" (500, 4.6 min)
      "https://www.youtube.com/playlist?list=PLwNv9Hhd8gZjNoQdpd2kBa3fwXNeJjzDX"
      # "Romantic Dinner Jazz" (243, 3.5 min)
      "https://www.youtube.com/playlist?list=PLmDmZHcjdZe1X2ZJV32UPXRwDQxRvDT-e"
      # "90's Love Songs" (71, 4.4 min)
      "https://www.youtube.com/playlist?list=PLNMTXgsQnLlCAYdQGh3sVAvun2hWZ_a6x"
    ];
  };

  calm = {
    words = [ "calm" "calm music" "relaxing" "relaxing music" "relax" "chill" "chill music" "peaceful" "something calm" ];
    artists = [ "Ólafur Arnalds" "Nils Frahm" "Max Richter" "Norah Jones" "Bon Iver" ];
    playlists = [
      # "30 Most Relaxing Songs of All Time" (30, 3.9 min)
      "https://www.youtube.com/playlist?list=PL3RlTwDWXaUE-uwu_nZkg2KYBX2_Qu3-v"
      # "Ólafur Arnalds & Nils Frahm" (17, 5.7 min)
      "https://www.youtube.com/playlist?list=PL7dZbc14svX3d_eX-wgB9Od1JseveH8JB"
      # "Norah Jones, Katie Melua, Colbie Caillat, Jack Johnson" (134, 3.5 min)
      "https://www.youtube.com/playlist?list=PL3byekiQByVxzQwQhm0h6DwKloKGwPBsR"
    ];
  };

  stretching = {
    words = [ "stretching" "stretching music" "yoga" "yoga music" "pilates" "cool down" ];
    artists = [ "Marconi Union" "Enya" "Moby" "Bonobo" ];
    playlists = [
      # "Yoga Playlist 2026 - Best Yoga Songs 2026" (40, 5.1 min)
      "https://www.youtube.com/playlist?list=PLChOO_ZAB22Vi5jLIhc5DP3jVfuQ9b9RE"
      # "Pilates Flow 2025" (193, 2.9 min)
      "https://www.youtube.com/playlist?list=PLY211hYNmayqoEsanUwrX-qm-9fuhu0Hl"
    ];
  };

  morning = {
    words = [ "morning" "morning music" "good morning" "wake up" "wake up music" "feel good" "feel good music" "breakfast music" ];
    artists = [ "Jack Johnson" "Norah Jones" "Jason Mraz" "Bill Withers" "Coldplay" ];
    playlists = [
      # "Morning Acoustic Playlist - Best Acoustic Sunrise Songs" (40, 3.7 min)
      "https://www.youtube.com/playlist?list=PLGXbBW1RbSb5xdnd0tz_3MFrN1kgtb5Sh"
      # "Songs That Will INSTANTLY Put You In A Good Mood" (90, 3.8 min)
      "https://www.youtube.com/playlist?list=PLJNlve0_Ebae2aPbjfolLT-6LvZkP8UZA"
      # "Jack Johnson, John Mayer, Dave Matthews, Ed Sheeran, ..." (75, 3.6 min)
      "https://www.youtube.com/playlist?list=PL9HGBOUXq6QGEeVHCixR_zRFX4T8vJ48z"
    ];
  };
}
