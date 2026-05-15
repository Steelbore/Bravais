# SPDX-License-Identifier: GPL-3.0-or-later
# Spacecraft Software Bravais — Hardware Module Entry Point
{ config, lib, pkgs, ... }:

{
  imports = [
    ./fingerprint.nix
    ./intel.nix
  ];
}
