{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "iridium";
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
    };
  };

  time.timeZone = "Australia/NSW";
  i18n.defaultLocale = "en_AU.UTF-8";

  powerManagement.cpuFreqGovernor = "performance";
  security.rtkit.enable = true;
  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.neia = ./home.nix;
  };

  users.users.neia = {
    isNormalUser = true;
    shell = pkgs.nushell;
    initialPassword = "meow";
    extraGroups = [
      "wheel"
      "audio"
      "dialout"
      "i2c"
      "input"
      "kvm"
      "libvirtd"
      "networkmanager"
      "podman"
      "video"
    ];
  };

  environment = {
    shells = [ pkgs.nushell ];
    sessionVariables = {
      NVD_BACKEND = "direct";
      LIBVA_DRIVER_NAME = "nvidia";
      NIXPKGS_ALLOW_UNFREE = "1";
    };
    systemPackages = with pkgs; [
      git
    ];
  };

  programs = {
    firefox.enable = true;
    hyprland.enable = true;
    dconf.enable = true;
    xfconf.enable = true;

    uwsm = {
      enable = true;
      waylandCompositors.hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/start-hyprland";
      };
    };

    thunar = {
      enable = true;
      plugins = [
        pkgs.thunar-archive-plugin
      ];
    };

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        curl
        icu
      ];
    };
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraProfile = ''

        '';
      };
    };
  };

  services = {
    gvfs.enable = true;
    tumbler.enable = true;
    xserver.videoDrivers = [ "nvidia" ];

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber = {
        enable = true;
        extraConfig."51-deprioritize-webcam-mic" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "node.name" = "~alsa_input.usb-046d_C922_Pro_Stream_Webcam.*"; }
              ];
              actions = {
                update-props = {
                  "priority.session" = 0;
                  "priority.driver" = 0;
                };
              };
            }
          ];
          default.clock.rate = 44100;
          default.clock.allowed-rates = [
            44100
            48000
            88200
            96000
          ];
          default.clock.quantum = 1024;
          default.clock.min-quantum = 1024;
        };
      };
    };

    wivrn = {
      enable = true;
      openFirewall = true;
      package = (pkgs.wivrn.override { cudaSupport = true; });
      steam.importOXRRuntimes = true;

      monadoEnvironment = {
        LH_DISCOVER_WAIT_MS = "15000";
        VR_OVERRIDE = "${pkgs.xrizer}/lib/xrizer";
        PROTON_VR_RUNTIME = "${pkgs.xrizer}/lib/xrizer";
      };

      config = {
        enable = true;
        json = {
          "use-steamvr-lh" = true;
        };
      };
    };
  };

  hardware = {
    steam-hardware.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = true;
      package = pkgs.linuxPackages.nvidiaPackages.production;
    };
    graphics = {
      enable = true;
      extraPackages = [
        pkgs.nvidia-vaapi-driver
      ];
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
    };
    channel.enable = false;
  };

  nixpkgs.overlays = [
    inputs.nix-vscode-extensions.overlays.default
  ];

  system.stateVersion = "26.11"; # Did you read the comment?

}
