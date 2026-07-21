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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.neia = ./home.nix;
  };

  users.users.neia = {
    isNormalUser = true;
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
    initialPassword = "meow";
    openssh.authorizedKeys.keys = [
    ];
    shell = pkgs.nushell;
  };

  environment.shells = [ pkgs.nushell ];

  programs = {
    firefox.enable = true;
    hyprland.enable = true;
    uwsm = {
      enable = true;
      waylandCompositors.hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/start-hyprland";
      };
    };
    dconf.enable = true;
    thunar = {
      enable = true;
      plugins = [
        pkgs.thunar-archive-plugin
      ];
    };
    xfconf.enable = true;

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

  environment.systemPackages = with pkgs; [
    git
  ];

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    gvfs.enable = true;
    tumbler.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
    pipewire.wireplumber.extraConfig."51-deprioritize-webcam-mic" = {
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

  hardware.steam-hardware.enable = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = true;

  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.nvidia-vaapi-driver
    ];
  };

  environment.sessionVariables = {
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  powerManagement.cpuFreqGovernor = "performance";

  security.rtkit.enable = true;

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

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  system.stateVersion = "26.11"; # Did you read the comment?

}
