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
    networkmanager.enable = true;
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJpJ8QLhZFEv9+/uArRW95YWDa8JEu2sbhmQ2gUnT9Xx gravy@FTP"
    ];
  };

  programs = {
    firefox.enable = true;
    hyprland.enable = true;
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
    };
    wivrn = {
      enable = true;
      openFirewall = true;
      autoStart = true;
      package = (pkgs.wivrn.override { cudaSupport = true; });
      steam.importOXRRuntimes = true;
    };
  };

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;

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
