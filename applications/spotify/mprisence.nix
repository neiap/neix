{
  pkgs,
  ...
}:

#show expanded rich presence in discord status
{
  systemd.user.services.mprisence = {
    Unit.Description = "Discord Rich Presence for MPRIS media players";
    Service = {
      ExecStart = "${pkgs.mprisence}/bin/mprisence";
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install.WantedBy = [ "default.target" ];
  };

  xdg.configFile."mprisence/config.toml".text = ''
    [template]
    state = "{{{artist_display}}} - {{{title}}}"

    [player.spotify]
    ignore = false
    allow_streaming = true
    app_id = "1531168563723767938"
    icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Spotify_icon.svg/960px-Spotify_icon.svg.png"
    show_icon = false
    status_display_type = "state"

    [web_player.spotify]
    match_patterns = ["open.spotify.com"]
    ignore = false
    allow_streaming = true
    app_id = "1531168563723767938"
    icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Spotify_icon.svg/960px-Spotify_icon.svg.png"
    show_icon = false
    status_display_type = "state"
  '';
}
