{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  probe = pkgs.writeShellApplication {
    name = "brightness-probe";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.ddcutil
      pkgs.gawk
    ];
    text = lib.readFile ./probe.sh;
  };

  watch = pkgs.writeShellApplication {
    name = "brightness-watch";
    runtimeInputs = [
      probe
      pkgs.coreutils
      pkgs.socat
    ];
    text = lib.readFile ./watch.sh;
  };

  brightness = pkgs.writeShellApplication {
    name = "brightness";
    runtimeInputs = [
      osConfig.programs.hyprland.package
      probe
      pkgs.coreutils
      pkgs.ddcutil
      pkgs.gawk
      pkgs.jq
      pkgs.libnotify
      pkgs.util-linux
    ];
    text = lib.readFile ./brightness.sh;
  };

  sessionUnit =
    description: extra:
    {
      Unit = {
        Description = description;
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    }
    // extra;
in
{
  home.packages = [
    brightness
    probe
    watch
  ];

  systemd.user.services = {
    # a full ddcutil scan is slow, so pay it at login instead of on the first keypress
    brightness-probe = sessionUnit "Probe external monitors for DDC/CI brightness buses" {
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = lib.getExe probe;
      };
    };

    brightness-watch = sessionUnit "Refresh the brightness bus map on monitor hotplug" {
      Service = {
        ExecStart = lib.getExe watch;
        Restart = "always";
        RestartSec = 2;
      };
    };
  };
}
