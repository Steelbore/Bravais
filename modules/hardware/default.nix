# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Hardware Module Entry Point
{ config, lib, pkgs, ... }:

{
  imports = [
    ./fingerprint.nix
    ./intel.nix
  ];
}
