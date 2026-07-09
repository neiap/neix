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
        };
      };
    };
  };

  home.packages = [
    pkgs.nixfmt-tree
    pkgs.claude-code
    pkgs.discord
    pkgs.steam
    pkgs.grimblast
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

}
