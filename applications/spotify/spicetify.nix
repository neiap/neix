{
  pkgs,
  inputs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;
    enabledExtensions =
      (with spicePkgs.extensions; [
        adblock
      ])
      ++ [
        {
          src = ./.;
          name = "notify-song-change.js";
        }
      ];
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";

    # override lyrics page background colour
    enabledSnippets = [
      ''
        .lyrics-lyrics-background { display: none; }
        .lyrics-lyrics-contentWrapper>*:not(.lyrics-lyricsContent-active, .lyrics-lyricsContent-highlight, .lyrics-lyricsContent-provider, .lyrics-lyricsContent-description, .lyrics-lyricsContent-unsynced) { color: #FFFFFF4D !important; }
        .lyrics-lyrics-contentWrapper>*:not(.lyrics-lyricsContent-active, .lyrics-lyricsContent-highlight, .lyrics-lyricsContent-provider, .lyrics-lyricsContent-description, .lyrics-lyricsContent-unsynced):hover { color: #FFFFFF !important; }
        .lyrics-lyricsContent-highlight { color: #FFFFFF66; }
        .lyrics-lyricsContent-unsynced { color: #FFFFFF !important; }
        .lyrics-lyricsContent-unsynced:hover { color: #FFFFFF !important; }
        .lyrics-lyricsContent-provider, .lyrics-lyricsContent-description { color: #FFFFFFB6 !important; }
      ''

      # remove 'now playing view'
      ''
        .Root__right-sidebar:has(.NowPlayingView) { width: 0 !important; overflow: hidden !important; }
        button:has(path[d='M11.196 8 6 5v6l5.196-3z']), button:has(path[d='M11.196 8 6 5v6z']) { display: none; }
      ''
    ];
  };
}
