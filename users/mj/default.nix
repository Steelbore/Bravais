# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — User System Configuration
{ config, pkgs, ... }:

{
  users.users.mj = {
    isNormalUser = true;
    description = "Mohamed Hammad";
    extraGroups = [ "networkmanager" "wheel" "input" "video" "audio" "docker" ];
    shell = pkgs.ion;
  };
}
