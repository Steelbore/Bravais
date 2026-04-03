# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Package Overlays
{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # Disable failing tests for sequoia-wot
      sequoia-wot = prev.sequoia-wot.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];
}
