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
    ./applications/firefox.nix
    ./applications/vscodium.nix
    ./applications/steam.nix
    ./applications/moonlight-config.nix
    ./applications/catppuccin-gtk.nix
    ./applications/vrcx
    ./applications/sidra
    inputs.steam-config-nix.homeModules.default
    inputs.moonlight.homeModules.default
    inputs.catppuccin.homeModules.catppuccin
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

  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    accent = "mauve";
    kitty.enable = true;
  };

  gtk.enable = true;
  catppuccin-workarounds.gtk.enable = true;

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
        # command to download catpuccin userstyles for import into stylus for firefox
        ctpuserstyles = ''bash -c "curl -sL https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json | sed -E 's/\"default\":\"(rosewater|flamingo|pink|mauve|red|maroon|peach|green|yellow|teal|blue|sapphire|grey|lavender)\"/\"default\":\"mauve\"/g' > ~/import.json"'';
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
  };

  home.packages = [
    pkgs.xrandr
    pkgs.nixfmt-tree
    pkgs.claude-code
    (pkgs.discord.override {
      withMoonlight = true;
      inherit (inputs.moonlight.packages.x86_64-linux) moonlight;
    })
    pkgs.grimblast
    pkgs.wl-clipboard
    pkgs.playerctl
    pkgs.libnotify
    pkgs.libva-utils
    pkgs.xivlauncher
    pkgs.wayvr
    pkgs.gimp
    pkgs.motoc
    pkgs.unityhub
    pkgs.alcom
    pkgs.file-roller
    pkgs.p7zip-rar
    pkgs.ayugram-desktop
    pkgs.mpv
    pkgs.blender
    pkgs.ffmpeg
    pkgs.thunderbird
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
