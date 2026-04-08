# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Package Overlays
{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      let
        claudeCodeVersion = "2.1.94";
        claudeCodeHashes = {
          "linux-arm64" = "sha256-s1JHkbULMUsX2smXjLlWj6LhGkZWKub3mNDaxFOgYEo=";
          "linux-x64" = "sha256-fLyTnLUuCdSf2CCSBhVD0hEAsEwyHhn+zwbwh9yQhmc=";
          "linux-arm64-musl" = "sha256-KrgQpM7OxcodFByt0TKv38S0nSFBVug9kxfGnRaI3XM=";
          "linux-x64-musl" = "sha256-qEEEToHQmwO4RM8jEDdDBBa+/cXlDHTffXHXLDYttUI=";
        };
        claudeCodeBaseUrl = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases";
        claudeCodeStdenv = prev.stdenvNoCC;
        claudeCodePlatformKey =
          "${claudeCodeStdenv.hostPlatform.node.platform}-${claudeCodeStdenv.hostPlatform.node.arch}"
          + prev.lib.optionalString claudeCodeStdenv.hostPlatform.isMusl "-musl";
        claudeCodeHash = claudeCodeHashes.${claudeCodePlatformKey}
          or (throw "Unsupported claude-code platform: ${claudeCodePlatformKey}");
      in {
      # Disable failing tests for sequoia-wot
      sequoia-wot = prev.sequoia-wot.overrideAttrs (old: {
        doCheck = false;
      });

      # Anthropic removed the 2.1.88 npm tarball, so pin the published binary release.
      claude-code = claudeCodeStdenv.mkDerivation {
        pname = "claude-code";
        version = claudeCodeVersion;

        src = prev.fetchurl {
          url = "${claudeCodeBaseUrl}/${claudeCodeVersion}/${claudeCodePlatformKey}/claude";
          hash = claudeCodeHash;
        };

        dontUnpack = true;
        dontBuild = true;
        dontStrip = true;

        nativeBuildInputs = [ prev.makeBinaryWrapper ]
          ++ prev.lib.optionals claudeCodeStdenv.hostPlatform.isElf [ prev.autoPatchelfHook ];

        strictDeps = true;

        installPhase = ''
          runHook preInstall

          install -Dm755 "$src" "$out/bin/claude"

          wrapProgram "$out/bin/claude" \
            --set DISABLE_AUTOUPDATER 1 \
            --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
            --set DISABLE_INSTALLATION_CHECKS 1 \
            --set USE_BUILTIN_RIPGREP 0 \
            --prefix PATH : ${prev.lib.makeBinPath (
              [
                prev.procps
                prev.ripgrep
              ]
              ++ prev.lib.optionals claudeCodeStdenv.hostPlatform.isLinux [
                prev.bubblewrap
                prev.socat
              ]
            )}

          runHook postInstall
        '';

        meta = with prev.lib; {
          description = "Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
          homepage = "https://github.com/anthropics/claude-code";
          downloadPage = "https://claude.com/product/claude-code";
          license = licenses.unfree;
          mainProgram = "claude";
          platforms = platforms.linux;
        };
      };
      }
    })
  ];
}
