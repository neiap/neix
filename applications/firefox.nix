{ pkgs, ... }:
let
  catppuccinMochaMauveAddonId = "{d090b7ee-a385-4d54-b9a4-f7164d17756d}";
  catppuccinMochaMauveTheme = pkgs.stdenv.mkDerivation {
    name = "catppuccin-mocha-mauve-theme";
    src = pkgs.fetchurl {
      url = "https://addons.mozilla.org/firefox/downloads/file/3954870/catppuccin_mocha_mauve-2.0.xpi";
      sha256 = "sha256-FDBkFFwYp93cvnxFsWK/8xjKqj7TpEhEDm26fSe7ThY=";
    };
    passthru.addonId = catppuccinMochaMauveAddonId;
    dontUnpack = true;
    installPhase = ''
      dst=$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}
      mkdir -p "$dst"
      install -m644 "$src" "$dst/${catppuccinMochaMauveAddonId}.xpi"
    '';
  };
in
{
  programs.firefox = {
    enable = true;
    package = null;

    profiles.default = {
      path = "6u0gf2tl.default";
      extensions.packages = [ catppuccinMochaMauveTheme ];
      settings."extensions.autoDisableScopes" = 0;

      search = {
        force = true;
        default = "ddg";
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
          "google".metaData.hidden = true;
        };
      };
    };
  };
}
