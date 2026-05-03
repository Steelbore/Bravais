# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Nix Settings
{ config, lib, pkgs, ... }:

{
  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Overlays
  nixpkgs.overlays = [
    (final: prev: {
      # Disable failing tests for sequoia-wot
      sequoia-wot = prev.sequoia-wot.overrideAttrs (old: {
        doCheck = false;
      });

      # Pin claude-code to latest npm release (2.1.113)
      claude-code = prev.claude-code.overrideAttrs (old: rec {
        version = "2.1.113";
        # Bake package-lock.json into src so both the main derivation
        # and fetchNpmDeps can see it (fetchNpmDeps unpacks src separately
        # and does not receive postPatch).
        src = prev.runCommand "claude-code-${version}-src" {} ''
          cp -r ${prev.fetchzip {
            url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
            hash = "sha256-VPAP15/GedLvE6bFZsvsrISUkI3RD1x3xFsQxm8drDs=";
          }} $out
          chmod -R u+w $out
          cp ${../../overlays/claude-code-package-lock.json} $out/package-lock.json
        '';
        npmDepsHash = "sha256-cXcl1m8puD8oSW+yL8Yb3GSt8bnrxQkrHxVD/LjwcTw=";
        # Must explicitly rebuild npmDeps — overrideAttrs does not propagate
        # src/npmDepsHash into buildNpmPackage's internal fetchNpmDeps call.
        npmDeps = prev.fetchNpmDeps {
          inherit src;
          name = "claude-code-${version}-npm-deps";
          hash = npmDepsHash;
        };
        # cli.js no longer exists in 2.1.113 (native binary architecture)
        postPatch = "";
        # autoPatchelfHook patches the ELF interpreter/RPATHs for NixOS
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ prev.autoPatchelfHook ];
        buildInputs = (old.buildInputs or []) ++ [ prev.stdenv.cc.cc.lib ];
        # Ignore musl libc — we only use the glibc binary (claude-code-linux-x64)
        autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];
        # Since ~2.1.113, claude-code ships a native binary via optional deps.
        # buildNpmPackage doesn't run postinstall, so we copy it manually.
        postInstall = ''
          # Find the native binary in node_modules
          nativeBin=$(find $out/lib/node_modules -path "*claude-code-linux-x64/claude" -type f 2>/dev/null | head -1)
          if [ -z "$nativeBin" ]; then
            echo "ERROR: claude-code native binary not found in node_modules"
            echo "Available claude-code packages:"
            find $out/lib/node_modules -path "*claude-code-linux*" -type d 2>/dev/null
            exit 1
          fi
          echo "Found native binary at: $nativeBin"
          # Replace the placeholder bin/claude.exe with the actual native binary
          cp "$nativeBin" $out/lib/node_modules/@anthropic-ai/claude-code/bin/claude.exe
          chmod +x $out/lib/node_modules/@anthropic-ai/claude-code/bin/claude.exe
          # Replace npm's Node.js launcher with a direct symlink to the native binary
          rm -f $out/bin/claude
          ln -s $out/lib/node_modules/@anthropic-ai/claude-code/bin/claude.exe $out/bin/claude
          ${old.postInstall or ""}
        '';
      });
    })
  ];
}
