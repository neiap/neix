{
  pkgs,
  inputs,
  ...
}:
{

  programs.steam.config = {
    enable = true;
    onSteamRunning = "close";
    defaultCompatTool = pkgs.proton-ge-bin;

    apps = {
      "VRChat" = {
        id = 438100;
        compatTool = inputs.nixpkgs-xr.packages."x86_64-linux".proton-rtsp-bin;
        launchOptions.env = {
          TZ = null;
          PROTON_VR_RUNTIME = "${pkgs.xrizer}/lib/xrizer";
          VR_OVERRIDE = "${pkgs.xrizer}/lib/xrizer";
          XRIZER_TRACKER_SERIALS = "LHR-47B90BBC;LHR-383B0B7D;LHR-DA140F05;LHR-D03ECB7F";
        };
      };
      "Counter Strike 2" = {
        id = 730;
      };
      "Elden Ring" = {
        id = 1245620;
        launchOptions.env = {
          PROTON_ENABLE_NVAPI = "1";
          DXVK_ASYNC = "1";
        };
      };
    };
  };
}
