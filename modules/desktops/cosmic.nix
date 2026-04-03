# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — COSMIC Desktop Environment (Wayland)
{ config, lib, pkgs, ... }:

{
  options.steelbore.desktops.cosmic = {
    enable = lib.mkEnableOption "COSMIC Desktop Environment (Wayland)";
  };

  config = lib.mkIf config.steelbore.desktops.cosmic.enable {
    # Enable COSMIC (native nixpkgs/NixOS module)
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = false; # Use greetd
  };
}
