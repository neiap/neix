{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.vscodium = {
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
}
