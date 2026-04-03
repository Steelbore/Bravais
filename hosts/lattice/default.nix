# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Host Configuration
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # Hostname
  networking.hostName = "lattice";
  networking.networkmanager.enable = true;

  # X11 (for LeftWM)
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us,ar";
    options = "grp:ctrl_space_toggle";
  };

  # Printing
  services.printing.enable = true;

  # User account
  users.users.mj = {
    isNormalUser = true;
    description = "Mohamed Hammad";
    extraGroups = [ "networkmanager" "wheel" "input" "video" "audio" "docker" ];
    shell = pkgs.nushell;
  };

  # Steelbore module toggles
  steelbore = {
    # Desktop environments
    desktops.gnome.enable = true;
    desktops.cosmic.enable = true;
    desktops.niri.enable = true;
    desktops.leftwm.enable = true;

    # Hardware
    hardware.fingerprint.enable = true;
    hardware.intel.enable = true;

    # Package bundles
    packages.browsers.enable = true;
    packages.terminals.enable = true;
    packages.editors.enable = true;
    packages.development.enable = true;
    packages.security.enable = true;
    packages.networking.enable = true;
    packages.multimedia.enable = true;
    packages.productivity.enable = true;
    packages.system.enable = true;
    packages.ai.enable = true;
  };

  system.stateVersion = "25.11";
}
