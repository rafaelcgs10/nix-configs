# The "play ..." voice command for vovo (a Home Assistant automation).
#
# 1. Work out what was asked (parser below): random / artist / album /
#    playlist / genre, or plain "play X" where X could be anything.
# 2. Look in the library; plain "play X" tries, in order: an artist named
#    exactly X, a song whose title contains X, an album named exactly X.
# 3. Not in the library: fetch from YouTube (youtube.nix).
#
# "queue X" / "add X to the queue" / "play X next" add instead of replacing.
{ player }:

let
  # Normalise for comparisons: lower case, letters/digits/spaces only.
  norm = x: "(${x}) | lower | regex_replace('[^a-z0-9 ]', '') | trim";

  # Request parser. Rules are tried in order; the first match decides the
  # mode and its capture group is the name. Returns {'mode': .., 'name': ..}.
  parser = ''
    {%- set q = song | lower | regex_replace('[.!?,]+$', ''') | trim -%}
    {%- set rules = [
      ['random', '^(?:something|anything|whatever|anything good|some music|music|a song|some songs|songs|random|random music|random songs|my music|my songs)$'],
      ['artist', '^(?:songs|music|something|anything|stuff|tracks|more|more songs|more music) (?:by|from) (.+)$'],
      ['artist', '^(?:the )?(?:best|top|greatest|most popular) (?:songs |hits |tracks |music )?(?:by|of|from) (.+)$'],
      ['artist', '^(?:a |some )?(?:playlist|mix|selection) (?:of|with|by|from) (.+)$'],
      ['artist', '^(?:the )?artist (.+)$'],
      ['artist', '^(.+?)(?:\x27s)? (?:greatest hits|best songs|top songs|best hits|hits|radio|mix)$'],
      ['album', '^(?:the )?album (.+)$'],
      ['album', '^(?:the )?(.+) album$'],
      ['playlist', '^(?:the |a )?playlist (?:called |named )?(.+)$'],
      ['genre', '^(?:some )?(.+) music$'],
      ['plain', '^some (.+)$'],
    ] -%}
    {%- set ns = namespace(done=false, mode='plain', name=q) -%}
    {%- for r in rules if not ns.done -%}
      {%- set m = q | regex_findall(r[1]) -%}
      {%- if m -%}
        {%- set ns.done = true -%}
        {%- set ns.mode = r[0] -%}
        {%- set ns.name = (m[0] if r[0] != 'random' else q) | trim -%}
      {%- endif -%}
    {%- endfor -%}
    {{ {'mode': ns.mode, 'name': ns.name} }}
  '';

  say = text: { set_conversation_response = text; };

  playMedia = mediaId: mediaType: {
    action = "music_assistant.play_media";
    target.entity_id = player;
    data = { media_id = mediaId; media_type = mediaType; enqueue = "{{ enqueue }}"; };
  };

  youtube = kind: query: {
    action = "shell_command.youtube_fetch";
    data = { inherit kind query; option = "{{ enqueue }}"; };
  };

  # After a single requested song, queue 20 random library songs behind it so
  # the music keeps going and "next" has somewhere to go. (Music Assistant's
  # "don't stop the music" needs a streaming provider; local files don't.)
  fillQueue = {
    "if" = [ { condition = "template"; value_template = "{{ enqueue == 'replace' }}"; } ];
    "then" = [
      {
        action = "music_assistant.get_library";
        data = { config_entry_id = "{{ ma_entry }}"; media_type = "track"; order_by = "random"; limit = 20; };
        response_variable = "fill";
      }
      {
        action = "music_assistant.play_media";
        target.entity_id = player;
        data = { media_id = "{{ fill['items'] | map(attribute='uri') | list }}"; media_type = "track"; enqueue = "add"; };
      }
    ];
  };

  search = mediaType: name: extra: resultVar: {
    action = "music_assistant.search";
    data = {
      config_entry_id = "{{ ma_entry }}";
      inherit name;
      media_type = mediaType;
      library_only = true;
      limit = 1;
    } // extra;
    response_variable = resultVar;
  };

  # Play an artist found in the library (shuffled; with "replace" only).
  playArtist = res: [
    {
      "if" = [ { condition = "template"; value_template = "{{ enqueue == 'replace' }}"; } ];
      "then" = [ { action = "media_player.shuffle_set"; target.entity_id = player; data.shuffle = true; } ];
    }
    (playMedia "{{ ${res}.artists[0].uri }}" "artist")
    (say "{{ verb }} music by {{ ${res}.artists[0].name }}.")
  ];

  playAlbum = res: [
    {
      "if" = [ { condition = "template"; value_template = "{{ enqueue == 'replace' }}"; } ];
      "then" = [ { action = "media_player.shuffle_set"; target.entity_id = player; data.shuffle = false; } ];
    }
    (playMedia "{{ ${res}.albums[0].uri }}" "album")
    (say "{{ verb }} the album {{ ${res}.albums[0].name }} by {{ ${res}.albums[0].artists | map(attribute='name') | join(' and ') }}.")
  ];

  playTrack = res: [
    (playMedia "{{ ${res}.tracks[0].uri }}" "track")
    (say "{{ verb }} {{ ${res}.tracks[0].name }} by {{ ${res}.tracks[0].artists | map(attribute='name') | join(' and ') }}.")
    fillQueue
  ];

  cond = t: [ { condition = "template"; value_template = t; } ];

  # Library hit checks
  artistIs = res: wanted: "{{ ${res}.artists | length > 0 and ${norm "${res}.artists[0].name"} == ${norm wanted} }}";
  albumIs = res: wanted: "{{ ${res}.albums | length > 0 and ${norm "${res}.albums[0].name"} == ${norm wanted} }}";
  # A fuzzy search always finds *something*; only accept a song whose title
  # contains the words that were asked for ("play queen" must not pick
  # "Dancing Queen" when Queen is the artist; that case is caught earlier).
  titleHas = res: wanted: "{{ ${res}.tracks | length > 0 and ${norm wanted} != '' and ${norm wanted} in ${norm "${res}.tracks[0].name"} }}";
in
{
  id = "vovo_play_song";
  alias = "vovo - play music";
  mode = "single";
  triggers = [
    {
      trigger = "conversation";
      id = "replace";
      command = [
        "play {song}"
        "put on {song}"
        "I want to (hear|listen to) {song}"
        "let me (hear|listen to) {song}"
        "can you play {song}"
      ];
    }
    {
      trigger = "conversation";
      id = "add";
      command = [
        "queue {song}"
        "add {song} to the queue"
        "add {song} to the list"
      ];
    }
    {
      trigger = "conversation";
      id = "next";
      command = [
        "play {song} next"
        "play {song} after this [song]"
      ];
    }
  ];
  actions = [
    {
      # Nix emits attributes alphabetically: a variable cannot use another
      # one from the same block, hence several blocks.
      variables = {
        inherit player;
        ma_entry = "{{ config_entry_id('${player}') }}";
        # "play X next" also matches "play {song}" (which trigger wins is not
        # reliable), so a trailing "next" / "after this" is handled here too.
        song = "{{ trigger.slots.song | regex_replace('(?i) (next|after this( song)?)$', '') | trim }}";
        enqueue = "{{ 'next' if (trigger.slots.song | lower | trim) is match('.* (next|after this( song)?)$') else trigger.id }}";
      };
    }
    {
      variables = {
        req = parser;
        verb = "{{ {'replace': 'Playing', 'add': 'Added to the queue:', 'next': 'Up next:'}[enqueue] }}";
      };
    }
    {
      variables = {
        mode = "{{ req.mode }}";
        name = "{{ req.name }}";
      };
    }
    {
      variables = {
        title = "{{ (name.split(' by ') | first) | trim }}";
        by = "{{ (name.split(' by ')[1] if ' by ' in name else '') | trim }}";
      };
    }
    {
      choose = [
        # --- random ----------------------------------------------------------
        {
          conditions = "{{ mode == 'random' }}";
          sequence = [
            {
              action = "music_assistant.get_library";
              data = { config_entry_id = "{{ ma_entry }}"; media_type = "track"; order_by = "random"; limit = "{{ 25 if enqueue == 'replace' else 10 }}"; };
              response_variable = "lib";
            }
            (playMedia "{{ lib['items'] | map(attribute='uri') | list }}" "track")
            (say "{{ 'Shuffling your library. First up: ' ~ lib['items'][0].name ~ '.' if enqueue == 'replace' else 'Added some random songs to the queue.' }}")
          ];
        }
        # --- artist ----------------------------------------------------------
        {
          conditions = "{{ mode == 'artist' }}";
          sequence = [
            (search "artist" "{{ name }}" { } "found")
            {
              "if" = cond "{{ found.artists | length > 0 }}";
              "then" = playArtist "found";
              "else" = [
                (youtube "artist" "{{ name }}")
                (say "I don't have music by {{ name }}, so I'm getting their top songs from YouTube. One moment.")
              ];
            }
          ];
        }
        # --- album -----------------------------------------------------------
        {
          conditions = "{{ mode == 'album' }}";
          sequence = [
            (search "album" "{{ title }}" { artist = "{{ by }}"; } "found")
            {
              "if" = cond "{{ found.albums | length > 0 }}";
              "then" = playAlbum "found";
              "else" = [
                (youtube "album" "{{ name }}")
                (say "I don't have the album {{ title }}, so I'm getting it from YouTube. One moment.")
              ];
            }
          ];
        }
        # --- playlist: YouTube only (max 20 songs) --------------------------
        {
          conditions = "{{ mode == 'playlist' }}";
          sequence = [
            (youtube "playlist" "{{ name }}")
            (say "Getting the playlist {{ name }} from YouTube. One moment.")
          ];
        }
        # --- genre / mood ("rock music", "80s music"): a YouTube playlist ----
        {
          conditions = "{{ mode == 'genre' }}";
          sequence = [
            (youtube "playlist" "{{ name }} music")
            (say "Getting a {{ name }} playlist from YouTube. One moment.")
          ];
        }
      ];
      # --- plain "play X": artist? song? album? else YouTube ----------------
      default = [
        (search "artist" "{{ name }}" { } "as_artist")
        {
          "if" = cond (artistIs "as_artist" "name");
          "then" = playArtist "as_artist";
          "else" = [
            (search "track" "{{ title }}" { artist = "{{ by }}"; } "as_track")
            {
              "if" = cond (titleHas "as_track" "title");
              "then" = playTrack "as_track";
              "else" = [
                (search "album" "{{ name }}" { } "as_album")
                {
                  "if" = cond (albumIs "as_album" "name");
                  "then" = playAlbum "as_album";
                  "else" = [
                    (youtube "song" "{{ name }}")
                    (say "{{ title }} isn't in your library, so I'm getting it from YouTube. One moment.")
                  ];
                }
              ];
            }
          ];
        }
      ];
    }
  ];
}
