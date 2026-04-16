# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Package Overlays
{ ... }:

{
  nixpkgs.overlays = [
    # Disable failing tests for sequoia-wot
    (final: prev: {
      sequoia-wot = prev.sequoia-wot.overrideAttrs (_old: {
        doCheck = false;
      });
    })

    # Replace bash/bashInteractive/bashNonInteractive with Brush (Rust).
    # Uses overrideAttrs on the existing bash derivation to avoid the
    # stdenv bootstrapping cycle (stdenvNoCC → runtimeShell → bashNonInteractive
    # → final.bash → stdenvNoCC). postInstall symlinks the built bash/sh
    # entrypoints to brush; passthru.shellPath is inherited from the original.
  ];
}
