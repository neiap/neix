{ pkgs, lib, ... }:
let
  vr-session = pkgs.writeShellApplication {
    name = "vr-session";
    runtimeInputs = with pkgs; [
      motoc
      procps
      systemd
      util-linux
    ];
    text = lib.readFile ./vr-session.sh;
  };
in
{
  home.packages = [ vr-session ];
}
