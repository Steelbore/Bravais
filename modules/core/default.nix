# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Core Module Entry Point
{ config, lib, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./nix.nix
    ./locale.nix
    ./audio.nix
    ./security.nix
  ];
}
