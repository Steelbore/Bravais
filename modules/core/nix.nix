# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Nix Settings
{ config, lib, pkgs, ... }:

{
  imports = [
    ../../overlays/default.nix
  ];

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
}
