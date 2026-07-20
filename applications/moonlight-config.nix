{ ... }:
{
  programs.moonlight = {
    enable = true;
    configs.stable = {
      extensions = {
        alwaysFocus = true;
        alwaysShowForwardTime = true;
        antinonce = true;
        betterCodeblocks = true;
        betterEmbedsYT = true;
        betterTags = true;
        callIdling = true;
        callTimer = true;
        clearUrls = true;
        cloneExpressions = true;
        colorConsistency = true;
        copyAvatarUrl = true;
        copyWebp = true;
        disableSentry = true;
        domOptimizer = true;
        favouriteGifSearch = true;
        freeMoji = true;
        freeScreenShare = true;
        freeStickers = true;
        imageViewer = true;
        jumpToBlocked = true;
        mediaTweaks = {
          config = {
            imageUrls = false;
            noGifAutosend = false;
            noStickerAutosend = false;
            openGifPickerFavorites = false;
            videoMetadata = false;
          };
          enabled = true;
        };
        memberCount = true;
        mentionAvatars = true;
        moonbase = {
          config = {
            updateBanner = true;
            updateChecking = true;
          };
          enabled = true;
        };
        nativeFixes = {
          config = {
            disableRendererBackgrounding = false;
            linuxSpeechDispatcher = true;
            vulkan = false;
          };
          enabled = true;
        };
        neatSettingsContext = true;
        noHelp = true;
        noJoinMessageWave = true;
        noMaskedLinkPaste = true;
        noOnboardingDelay = true;
        noReplyChainNag = true;
        noRpc = true;
        noTrack = true;
        onePingPerDM = {
          config = {
            allowAtEveryoneBypass = true;
            allowMentionsBypass = true;
            typeOfDM = "group_dm";
          };
          enabled = true;
        };
        openExternally = {
          config = {
            spotify = false;
          };
          enabled = true;
        };
        ownerCrown = true;
        replyChain = true;
        resolver = true;
        sendTimestamps = true;
        showAllRoles = true;
        showMediaOptions = true;
        showReplySelf = true;
        svgEmbed = true;
        typingTweaks = true;
        unindent = true;
        whoJoined = {
          config = {
            serverNicknames = false;
          };
          enabled = true;
        };
      };
      repositories = [
        "https://moonlight-mod.github.io/extensions-dist/repo.json"
      ];
    };
  };

  xdg.configFile."moonlight-mod/stable.json".force = true;
}
