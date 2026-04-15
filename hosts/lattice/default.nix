# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Host Configuration
{
  config,
  pkgs,
  lib,
  ...
}:

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
    layout = "us,ara";
    options = "grp:ctrl_space_toggle";
  };

  # ckbcomp can't resolve multi-layout XKB configs; keep console on US
  console.keyMap = "us";

  # Printing
  services.printing.enable = true;

  # User account
  users.users.mj = {
    isNormalUser = true;
    description = "Mohamed Hammad";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "video"
      "audio"
    ];
    shell = pkgs.nushell;
  };

  # Root shell — Brush (Rust, Bash-compatible)
  users.users.root.shell = pkgs.brush;

  # Register shells as valid login shells
  # Ion kept as an available shell (not the default)
  environment.shells = [ pkgs.nushell pkgs.brush pkgs.ion ];

  # Disable Bash as a login shell — use memory-safe alternatives
  programs.bash.enable = false;

  # Steelbore module toggles
  steelbore = {
    # Desktop environments
    desktops.gnome.enable = true;
    desktops.cosmic.enable = true;   # stable pkgs (nixos-25.11)
    desktops.plasma.enable = true;
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
    packages.flatpak.enable = true;
  };

  system.stateVersion = "25.11";
}
