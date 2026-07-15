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
    file.".config/wivrn/config.json".text = builtins.toJSON {
      # wivrn-dashboard reads this directly (unlike wivrn.service, which uses
      # its own Nix-generated config from configuration.nix); without it the
      # SteamVR lighthouse driver never starts and trackers never show up.
      "use-steamvr-lh" = true;
    };
    file.".steam/steam/steam_dev.cfg".text = ''
      @nClientDownloadEnableHTTP2PlatformLinux 0
      @fDownloadRateImprovementToAddAnotherConnection 1.0
    '';
  };

  programs = {
    home-manager.enable = true;
    kitty.enable = true;
    fastfetch.enable = true;
    bash.enable = true;
    btop.enable = true;
    nushell = {
      enable = true;
      shellAliases = {
        start-hyprland = "uwsm start -- /run/current-system/sw/bin/start-hyprland";
      };
      extraEnv = ''
        $env.PROMPT_COMMAND = {||
          $"(ansi purple_bold)($env.USER)(ansi reset)@(ansi cyan_bold)(sys host | get hostname)(ansi reset) (ansi green_bold)($env.PWD)(ansi reset)"
        }
      '';
    };
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

    firefox = {
      enable = true;
      package = null; # already installed via programs.firefox.enable in configuration.nix

      profiles.default = {
        path = "6u0gf2tl.default";

        search = {
          force = true;
          default = "kagi";
          engines = {
            kagi = {
              name = "Kagi";
              urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
              definedAliases = [ ":kg" ];
            };

            nixos-options = {
              name = "NixOS Options";
              urls = [
                {
                  template = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={searchTerms}";
                }
              ];
              definedAliases = [ ":no" ];
            };

            nixpkgs = {
              name = "Nix Packages";
              urls = [
                {
                  template = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={searchTerms}";
                }
              ];
              definedAliases = [ ":np" ];
            };

            noogle = {
              name = "Noogle";
              urls = [ { template = "https://noogle.dev/q?term={searchTerms}"; } ];
              definedAliases = [ ":ng" ];
            };

            proton-db = {
              name = "ProtonDB";
              urls = [ { template = "https://www.protondb.com/search?q={searchTerms}"; } ];
              definedAliases = [ ":pd" ];
            };

            youtube = {
              name = "Youtube";
              urls = [ { template = "https://www.youtube.com/results?search_query={searchTerms}"; } ];
              definedAliases = [ ":yt" ];
            };

            "Wikipedia".metaData.hidden = true;
            "bing".metaData.hidden = true;
            "ddg".metaData.hidden = true;
            "google".metaData.hidden = true;
          };
        };
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
    pkgs.playerctl
    pkgs.vrcx
    pkgs.libnotify
    pkgs.libva-utils
    pkgs.xivlauncher
    pkgs.wayvr
    inputs.sidra.packages.x86_64-linux.default
    (pkgs.prismlauncher.override {
      jdks = with pkgs; [
        temurin-bin
        temurin-bin-17
        temurin-bin-25
      ];
    })
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
        launchOptions.env = {
          TZ = null;
          PROTON_VR_RUNTIME = "${pkgs.xrizer}/lib/xrizer";
          VR_OVERRIDE = "${pkgs.xrizer}/lib/xrizer";
          XRIZER_TRACKER_SERIALS = "LHR-47B90BBC;LHR-383B0B7D;LHR-DA140F05;LHR-D03ECB7F";
        };
      };
      "Counter Strike 2" = {
        id = 730;
        launchOptions.env = {
          SDL_VIDEO_DRIVER = "wayland";
        };
      };
    };
  };

  services = {
    easyeffects.enable = true;
    mako = {
      enable = true;
      settings = {
        "app-name=Sidra" = {
          default-timeout = 5000;
          ignore-timeout = true;
        };
      };
    };
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
