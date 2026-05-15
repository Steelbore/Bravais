# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Web Browsers
{ config, lib, pkgs, ... }:

{
  options.spacecraft.packages.browsers = {
    enable = lib.mkEnableOption "Web browsers";
  };

  config = lib.mkIf config.spacecraft.packages.browsers.enable {
    # Firefox (system-managed)
    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
      google-chrome
      brave
      librewolf
    ];
  };
}
