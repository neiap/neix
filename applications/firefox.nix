{ ... }:
{
  programs.firefox = {
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
}
