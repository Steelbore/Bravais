# SPDX-License-Identifier: GPL-3.0-or-later
# Spacecraft Software Bravais — Core Module Entry Point
{ config, lib, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./nix.nix
    ./nix-tmp.nix
    ./locale.nix
    ./audio.nix
    ./security.nix
    ./dns.nix
  ];
}
