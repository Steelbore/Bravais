# SPDX-License-Identifier: GPL-3.0-or-later
# Spacecraft Software Bravais — User System Configuration
{ config, pkgs, ... }:

{
  users.users.mj = {
    isNormalUser = true;
    description = "Mohamed Hammad";
    extraGroups = [ "networkmanager" "wheel" "input" "video" "audio" ];
    shell = pkgs.nushell;
  };
}
