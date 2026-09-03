# patch has to land in the store, the wrapper re-links ~/.config/discord modules every launch
{ pkgs, inputs, ... }:
let
  discordArgs = {
    withMoonlight = true;
    inherit (inputs.moonlight.packages.x86_64-linux) moonlight;
  };

  patchedUnwrapped =
    (pkgs.discord.override discordArgs).passthru.unwrappedDiscord.overrideAttrs
      (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.python3 ];
        postInstall = (old.postInstall or "") + ''
          python3 ${./vulkan-encode-patch.py} \
            "$out/opt/Discord/modules/discord_voice/index.js"
        '';
      });
in
{
  home.packages = [
    (pkgs.discord.override (discordArgs // { unwrappedDiscord = patchedUnwrapped; }))
  ];
}
