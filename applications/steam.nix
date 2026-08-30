{
  config,
  pkgs,
  inputs,
  ...
}:
{

  home.file."Pictures/VRChat" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/Steam/steamapps/compatdata/438100/pfx/drive_c/users/steamuser/Pictures/VRChat";
    force = true;
  };

  programs.steam.config = {
    enable = true;
    onSteamRunning = "close";
    defaultCompatTool = pkgs.proton-ge-bin;

    apps = {
      "438100" = {
        name = "vrchat";
        compatTool = inputs.nixpkgs-xr.packages."x86_64-linux".proton-rtsp-bin;
        launchOptions.env = {
          TZ = null;
          STEAMVIDEOTOKEN = "32f5h290g53047gv5034nbvt923b";
          PROTON_VR_RUNTIME = "${pkgs.xrizer}/lib/xrizer";
          VR_OVERRIDE = "${pkgs.xrizer}/lib/xrizer";
          XRIZER_TRACKER_SERIALS = "LHR-47B90BBC;LHR-383B0B7D;LHR-D03ECB7F";
        };
        launchOptions.args = [ "--ignore-trackers=LHR-DA140F05" ];
      };

      "730" = {
        name = "cs2";
      };

      "1245620" = {
        name = "elden ring";
        launchOptions.env = {
          PROTON_ENABLE_NVAPI = "1";
          DXVK_ASYNC = "1";
        };
      };
    };
  };
}
