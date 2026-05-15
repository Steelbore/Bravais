# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Theme Module Entry Point
{ config, lib, pkgs, spacecraftPalette, ... }:

{
  imports = [
    ./fonts.nix
    ./dark-mode.nix
  ];

  # Environment variables for theme-aware applications
  environment.variables = {
    SPACECRAFT_BACKGROUND = spacecraftPalette.voidNavy;
    SPACECRAFT_TEXT       = spacecraftPalette.moltenAmber;
    SPACECRAFT_ACCENT     = spacecraftPalette.steelBlue;
    SPACECRAFT_SUCCESS    = spacecraftPalette.radiumGreen;
    SPACECRAFT_WARNING    = spacecraftPalette.redOxide;
    SPACECRAFT_INFO       = spacecraftPalette.liquidCool;
  };

  # TTY / Virtual Console Colors (Spacecraft Software Palette)
  console.colors = [
    # Normal: Black Red Green Yellow Blue Magenta Cyan White
    "000027" "FF5C5C" "50FA7B" "D98E32" "4B7EB0" "4B7EB0" "8BE9FD" "D98E32"
    # Bright: Black Red Green Yellow Blue Magenta Cyan White
    "4B7EB0" "FF5C5C" "50FA7B" "D98E32" "8BE9FD" "8BE9FD" "8BE9FD" "D98E32"
  ];
}
