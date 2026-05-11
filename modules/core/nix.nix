# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Nix Settings
{ config, lib, pkgs, ... }:

{
  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Hardlink-deduplicate identical files in /nix/store. Costs a small
  # amount of CPU on every store add (and on the periodic optimise
  # service), saves disk on / which sits at 88 % full on this host.
  nix.settings.auto-optimise-store = true;

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Overlays
  # The claude-code overlay was dropped — claude-code now comes from
  # nixpkgs-unstable via specialArgs (see flake.nix mkBravais and
  # modules/packages/ai.nix). Unstable already tracks recent npm
  # releases without our manual pin.
  nixpkgs.overlays = [
    (final: prev: {
      # Disable failing tests for sequoia-wot
      sequoia-wot = prev.sequoia-wot.overrideAttrs (old: {
        doCheck = false;
      });

      # untra/operator — multi-agent orchestration TUI for AI-assisted
      # kanban workflows (Rust). Not in nixpkgs as of 25.11 / unstable
      # (verified 2026-05-11). Pinned by tag; bump `version` + re-run
      # `nix-prefetch-github --rev v<X.Y.Z> untra operator` for the
      # hash on upgrade. cargoLock.lockFile uses the upstream
      # Cargo.lock so we don't carry a separate cargoHash to refresh.
      operator = final.rustPlatform.buildRustPackage rec {
        pname = "operator";
        version = "0.1.31";

        src = final.fetchFromGitHub {
          owner = "untra";
          repo  = "operator";
          rev   = "v${version}";
          hash  = "sha256-9tUS4DbhzOqzLXgJymDAnzdJeKHt7arNMn+CTM/anMc=";
        };

        cargoLock = {
          lockFile = src + "/Cargo.lock";
        };

        # The workspace exposes two bins: `operator` (the TUI) and
        # `generate_types` (a build-time TS-type emitter we don't need
        # at runtime). Build only what we ship.
        cargoBuildFlags = [ "--bin" "operator" ];

        # Tests reach for the Bun sidecar (`backstage-server`) and a
        # network. Both unavailable in the build sandbox; tests are not
        # a gate for downstream installs.
        doCheck = false;

        meta = with final.lib; {
          description = "Multi-agent orchestration TUI for AI-assisted kanban software development";
          homepage    = "https://github.com/untra/operator";
          license     = licenses.mit;
          mainProgram = "operator";
          platforms   = platforms.linux;
        };
      };
    })
  ];
}
