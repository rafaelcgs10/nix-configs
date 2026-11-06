# The "play ..." voice command for vovo (a Home Assistant automation).
#
# 1. Work out what was asked (parser below): random / artist / album /
#    playlist / genre, or plain "play X" where X could be anything.
#    Then correct misheard names against a big artist/song list (names.nix).
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
      ['next_song', '^(?:the )?(?:next|next song|next one|next track|another song|another one|something else|a different song|a different one)$'],
      ['previous_song', '^(?:the )?(?:previous|previous song|previous one|previous track|last song|last one)$'],
      ['again', '^(?:(?:it|this|that|this song|that song|the song) )?again$'],
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
  # Texts come from phrases.nix (random variants).
  p = (import ./say.nix).pick;

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
    (say "{% set artist = ${res}.artists[0].name %}${p "playing_artist"}")
  ];

  playAlbum = res: [
    {
      "if" = [ { condition = "template"; value_template = "{{ enqueue == 'replace' }}"; } ];
      "then" = [ { action = "media_player.shuffle_set"; target.entity_id = player; data.shuffle = false; } ];
    }
    (playMedia "{{ ${res}.albums[0].uri }}" "album")
    (say "{% set album = ${res}.albums[0].name %}{% set artist = ${res}.albums[0].artists | map(attribute='name') | join(' and ') %}${p "playing_album"}")
  ];

  playTrack = res: [
    (playMedia "{{ ${res}.tracks[0].uri }}" "track")
    (say "{% set title = ${res}.tracks[0].name %}{% set artist = ${res}.tracks[0].artists | map(attribute='name') | join(' and ') %}${p "playing_track"}")
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
        song = "{{ trigger.slots.song | regex_replace('(?i) (next|after this( song)?)$', '') | regex_replace('(?i) (from|on) youtube( music)?$', '') | trim }}";
        # "play X from YouTube": skip the "I don't know that one" check below.
        force_youtube = "{{ (trigger.slots.song | lower | trim) is match('.* (from|on) youtube( music)?$') }}";
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
    # Snap misheard artist/song names onto known ones (names.nix): "Billy
    # Gene" -> "Billie Jean by Michael Jackson", "songs by chaikovsky" ->
    # Pyotr Ilyich Tchaikovsky. It may also turn a plain request into an
    # artist one ("play radio ahead" -> artist Radiohead). On any failure the
    # request goes on unchanged.
    {
      action = "rest_command.vovo_names";
      data = { mode = "{{ mode }}"; name = "{{ name }}"; };
      response_variable = "fixed";
      continue_on_error = true;
    }
    {
      variables = {
        ok = "{{ fixed is defined and fixed.status | default(0) == 200 and fixed.content is mapping and fixed.content.changed | default(false) }}";
        # vovo-names answered but knows nothing like it: probably misheard
        # ("chicosy" for Tchaikovsky). Then ask instead of playing a random
        # YouTube hit; "play X from YouTube" still searches.
        unknown = "{{ fixed is defined and fixed.status | default(0) == 200 and fixed.content is mapping and not fixed.content.changed | default(true) and fixed.content.mode == 'plain' and ' by ' not in fixed.content.name | lower }}";
      };
    }
    {
      variables = {
        mode = "{{ fixed.content.mode if ok else mode }}";
        name = "{{ fixed.content.name if ok else name }}";
      };
    }
    # Remember the request, so the music can continue in the same style
    # when the queue runs out (continue.nix).
    {
      action = "input_text.set_value";
      target.entity_id = "input_text.vovo_last_request";
      data.value = "{{ (mode ~ '|' ~ name)[:255] }}";
      continue_on_error = true;
    }
    {
      action = "input_datetime.set_datetime";
      target.entity_id = "input_datetime.vovo_last_request_at";
      data.timestamp = "{{ now().timestamp() }}";
      continue_on_error = true;
    }
    {
      variables = {
        title = "{{ (name.split(' by ') | first) | trim }}";
        by = "{{ (name.split(' by ')[1] if ' by ' in name else '') | trim }}";
      };
    }
    {
      choose = [
        # --- "play next", "play another song", "play it again": controls -----
        {
          conditions = "{{ mode == 'next_song' }}";
          sequence = import ./ha-next.nix { inherit player; };
        }
        {
          conditions = "{{ mode == 'previous_song' }}";
          sequence = [ { action = "media_player.media_previous_track"; target.entity_id = player; } (say (p "previous_song")) ];
        }
        {
          conditions = "{{ mode == 'again' }}";
          sequence = [ { action = "media_player.media_seek"; target.entity_id = player; data.seek_position = 0; } (say (p "from_the_top")) ];
        }
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
            (say "{% if enqueue == 'replace' %}{% set title = lib['items'][0].name %}${p "shuffling_library"}{% else %}${p "added_random"}{% endif %}")
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
                (say (p "searching_artist"))
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
                (say (p "searching_album"))
              ];
            }
          ];
        }
        # --- mood ("some lofi", recognised by vovo-names): moods.nix --------
        {
          conditions = "{{ mode == 'mood' }}";
          sequence = [
            (youtube "mood" "{{ name }}")
            (say (p "playing_mood"))
          ];
        }
        # --- playlist: YouTube only (max 20 songs) --------------------------
        {
          conditions = "{{ mode == 'playlist' }}";
          sequence = [
            (youtube "playlist" "{{ name }}")
            (say (p "getting_playlist"))
          ];
        }
        # --- genre / mood ("rock music", "80s music"): a YouTube playlist ----
        {
          conditions = "{{ mode == 'genre' }}";
          sequence = [
            (youtube "playlist" "{{ name }} music")
            (say (p "getting_genre"))
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
                    {
                      "if" = cond "{{ unknown and not force_youtube }}";
                      "then" = [
                        (say (p "unknown_name"))
                      ];
                      "else" = [
                        (youtube "song" "{{ name }}")
                        (say (p "searching_song"))
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
  ];
}
