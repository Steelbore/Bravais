# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Web Browsers
{ config, lib, pkgs, ... }:

{
  options.steelbore.packages.browsers = {
    enable = lib.mkEnableOption "Web browsers";
  };

  config = lib.mkIf config.steelbore.packages.browsers.enable {
    # Firefox (system-managed)
    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
      google-chrome
      brave
      microsoft-edge
      librewolf
    ];
  };
}
