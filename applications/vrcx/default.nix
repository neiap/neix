# custom.css vendored from https://github.com/different-name/nixxy/blob/master/diffy/shared/games/vrcx/custom.css
{ pkgs, ... }:
{
  home.packages = [
    pkgs.vrcx
  ];

  xdg.configFile."VRCX/custom.css".source = ./custom.css;
}
