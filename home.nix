{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./hyprland.nix ];

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
      flake = "/home/neia/config";
    };
    git = {
      enable = true;
      settings.user = {
        name = "neia";
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
        };
      };
    };
  };

  home.packages = [
    pkgs.nixfmt-tree
    pkgs.claude-code
  ];

  # This VM has no real GPU (see hyprland.nix), so LIBGL_ALWAYS_SOFTWARE=1 is
  # forced session-wide to avoid wl_surface crashes. VSCodium is Chromium-based
  # and would otherwise emulate GPU compositing through llvmpipe on every
  # repaint, causing CPU spikes. Disabling hardware acceleration makes it skip
  # GPU compositing entirely instead, which is far cheaper on a CPU rasterizer.
  home.file.".config/VSCodium/argv.json".text = builtins.toJSON {
    disable-hardware-acceleration = true;
  };

  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        configType = "hyprlang";
        settings = {
          env = [
            "WLR_NO_HARDWARE_CURSORS,1"
            "LIBGL_ALWAYS_SOFTWARE,1"
          ];
        };
      };
    };
  };

  systemd.user.services.vicinae.Service.Environment = [
    "QSG_RHI_BACKEND=software"
    "QT_QUICK_BACKEND=software"
    "LIBGL_ALWAYS_SOFTWARE=1"
  ];


}
