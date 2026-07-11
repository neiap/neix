{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hyprland.nix
    inputs.steam-config-nix.homeModules.default
  ];

  home = {
    username = "neia";
    homeDirectory = "/home/neia";
    stateVersion = "26.05";
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  programs = {
    home-manager.enable = true;
    kitty.enable = true;
    fastfetch.enable = true;
    bash.enable = true;
    htop.enable = true;
    vicinae = {
      enable = true;
      systemd.enable = true;
    };
    nh = {
      enable = true;
      flake = "/home/neia/neix";
    };
    git = {
      enable = true;
      settings.user = {
        name = "neiap";
        email = "neiap@proton.me";
      };
    };

    vscodium = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.nix-vscode-extensions.vscode-marketplace; [
          anthropic.claude-code
          jnoortheen.nix-ide
        ];
        userSettings = {
          # keep-sorted start block=yes newline_separated=yes
          "nix.enableLanguageServer" = true;

          "nix.hiddenLanguageServerErrors" = [
            # keep-sorted start
            "textDocument/codeAction"
            "textDocument/completion"
            "textDocument/definition"
            "textDocument/documentHighlight"
            "textDocument/documentLink"
            "textDocument/documentSymbol"
            "textDocument/hover"
            "textDocument/inlayHint"
            # keep-sorted end
          ];

          "nix.serverPath" = "${lib.getExe pkgs.nixd}";

          "nix.serverSettings.nixd.formatting.command" = [
            "${lib.getExe pkgs.nixfmt}"
          ];

          "nix.serverSettings.nixd.options.nixos.expr" =
            "(builtins.getFlake \"${config.programs.nh.flake}\").nixosConfigurations.<name>.options";
          # keep-sorted end
          "editor.formatOnSave" = true;
          "editor.guides.bracketPairs" = true;

          "editor.guides.bracketPairsHorizontal" = false;

          "editor.guides.highlightActiveBracketPair" = true;

          "workbench.colorCustomizations" = {
            # keep-sorted start
            "editorBracketPairGuide.activeBackground1" = "#f38ba8";
            "editorBracketPairGuide.activeBackground2" = "#fab387";
            "editorBracketPairGuide.activeBackground3" = "#f9e2af";
            "editorBracketPairGuide.activeBackground4" = "#a6e3a1";
            "editorBracketPairGuide.activeBackground5" = "#74c7ec";
            "editorBracketPairGuide.activeBackground6" = "#cba6f7";
            "editorBracketPairGuide.background1" = "#f38ba899";
            "editorBracketPairGuide.background2" = "#fab38799";
            "editorBracketPairGuide.background3" = "#f9e2af99";
            "editorBracketPairGuide.background4" = "#a6e3a199";
            "editorBracketPairGuide.background5" = "#74c7ec99";
            "editorBracketPairGuide.background6" = "#cba6f799";
          };
        };
      };
    };
  };

  home.packages = [
    pkgs.nixfmt-tree
    pkgs.claude-code
    pkgs.discord
    pkgs.grimblast
    pkgs.wl-clipboard
    pkgs.vrcx
    pkgs.libnotify
    pkgs.libva-utils
    pkgs.xivlauncher
  ];

  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        configType = "hyprlang";
        settings = {
        };
      };
    };
  };

  programs.steam.config = {
    enable = true;
    onSteamRunning = "close";
    defaultCompatTool = pkgs.proton-ge-bin;

    apps = {
      "VRChat" = {
        id = 438100;
        compatTool = inputs.nixpkgs-xr.packages."x86_64-linux".proton-rtsp-bin;
        launchOptions.env.TZ = null;
      };
    };
  };

  services = {
    easyeffects.enable = true;
    mako.enable = true;
    hyprpaper = {
      enable = true;
      settings = {
        wallpaper = [
          {
            monitor = "DP-1";
            path = "/home/neia/pictures/wall1.png";
          }
          {
            monitor = "DP-2";
            path = "/home/neia/pictures/wall1.png";
          }
          {
            monitor = "HDMI-A-1";
            path = "/home/neia/pictures/wall3.png";
          }
        ];
      };
    };
  };

}
