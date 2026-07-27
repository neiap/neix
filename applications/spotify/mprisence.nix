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

    [web_player.spotify]
    match_patterns = ["open.spotify.com"]
    ignore = false
    allow_streaming = true
  '';
}
