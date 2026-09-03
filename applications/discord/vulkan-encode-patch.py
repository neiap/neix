#!/usr/bin/env python3

import os
import sys

SITES = [
    # vaapi is decode-only on nvidia, route the encoder to nvenc
    (
        "        setTransportOptions: (options) => instance.setTransportOptions(options),",
        """        setTransportOptions: (options) => {
            let patchedOptions = options;
            if (process.platform === 'linux' &&
                options != null &&
                typeof options === 'object' &&
                typeof options.videoEncoderExperiments === 'string') {
                const values = [];
                const seen = new Set();
                for (const part of options.videoEncoderExperiments.split(',')) {
                    const token = part.trim();
                    if (!token || token === 'vaapi' || seen.has(token)) {
                        continue;
                    }
                    values.push(token);
                    seen.add(token);
                }
                for (const token of ['linux-nvenc', 'useCaptureDeviceForEncode']) {
                    if (seen.has(token)) {
                        continue;
                    }
                    values.push(token);
                    seen.add(token);
                }
                const nextVideoEncoderExperiments = values.join(',');
                if (nextVideoEncoderExperiments !== options.videoEncoderExperiments) {
                    patchedOptions = { ...options, videoEncoderExperiments: nextVideoEncoderExperiments };
                }
            }
            return instance.setTransportOptions(patchedOptions);
        },""",
    ),
    # encode off the capture device instead of round-tripping frames
    (
        "        setDesktopSourceWithOptions: (options) => instance.setDesktopSourceWithOptions(options),",
        """        setDesktopSourceWithOptions: (options) => {
            let patchedOptions = options;
            if (process.platform === 'linux' &&
                options != null &&
                typeof options === 'object' &&
                options.useCaptureDeviceForEncode !== true) {
                patchedOptions = { ...options, useCaptureDeviceForEncode: true };
            }
            return instance.setDesktopSourceWithOptions(patchedOptions);
        },""",
    ),
    (
        """VoiceEngine.createVoiceConnectionWithOptions = function (userId, connectionOptions, onConnectCallback) {
    const instance = new VoiceEngine.VoiceConnection(userId, connectionOptions, onConnectCallback);
    return bindConnectionInstance(instance);
};""",
        """VoiceEngine.createVoiceConnectionWithOptions = function (userId, connectionOptions, onConnectCallback) {
    let patchedConnectionOptions = connectionOptions;
    if (process.platform === 'linux' && connectionOptions != null && typeof connectionOptions === 'object') {
        const experiments = Array.isArray(connectionOptions.experiments) ? [...connectionOptions.experiments] : [];
        if (!experiments.includes('linux-vulkan')) {
            experiments.push('linux-vulkan');
            patchedConnectionOptions = { ...connectionOptions, experiments };
        }
    }
    const instance = new VoiceEngine.VoiceConnection(userId, patchedConnectionOptions, onConnectCallback);
    return bindConnectionInstance(instance);
};""",
    ),
]


def main() -> int:
    target = sys.argv[1]
    with open(target, encoding="utf-8") as handle:
        source = handle.read()

    for index, (old, new) in enumerate(SITES, start=1):
        found = source.count(old)
        if found != 1:
            print(
                f"discord vulkan-encode patch: site {index} matched {found} times, "
                f"expected exactly 1.\n"
                f"\n"
                f"Discord's discord_voice/index.js changed shape in this version.\n"
                f"To re-derive, dump the new stock file:\n"
                f"\n"
                f"  nix build --impure --no-link --print-out-paths --expr '\\\n"
                f"    (builtins.getFlake \"/home/neia/neix\")\\\n"
                f"    .nixosConfigurations.iridium.pkgs.discord.passthru.unwrappedDiscord'\n"
                f"\n"
                f"then read opt/Discord/modules/discord_voice/index.js and update the\n"
                f"failing SITES entry below to match the new text verbatim. The three\n"
                f"targets are setTransportOptions, setDesktopSourceWithOptions, and\n"
                f"VoiceEngine.createVoiceConnectionWithOptions.\n"
                f"\n"
                f"To ship without hardware encoding in the meantime, drop the\n"
                f"./applications/discord import from home.nix.",
                file=sys.stderr,
            )
            return 1
        source = source.replace(old, new)

    # extracted read-only from the distro tarball
    os.chmod(target, 0o644)
    with open(target, "w", encoding="utf-8") as handle:
        handle.write(source)

    print(f"discord vulkan-encode patch: applied {len(SITES)} sites to {target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
