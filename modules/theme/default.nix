# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Theme Module Entry Point
{ config, lib, pkgs, steelborePalette, ... }:

{
  imports = [
    ./fonts.nix
  ];

  # Environment variables for theme-aware applications
  environment.variables = {
    STEELBORE_BACKGROUND = steelborePalette.voidNavy;
    STEELBORE_TEXT       = steelborePalette.moltenAmber;
    STEELBORE_ACCENT     = steelborePalette.steelBlue;
    STEELBORE_SUCCESS    = steelborePalette.radiumGreen;
    STEELBORE_WARNING    = steelborePalette.redOxide;
    STEELBORE_INFO       = steelborePalette.liquidCool;
  };

  # TTY / Virtual Console Colors (Steelbore Palette)
  console.colors = [
    # Normal: Black Red Green Yellow Blue Magenta Cyan White
    "000027" "FF5C5C" "50FA7B" "D98E32" "4B7EB0" "4B7EB0" "8BE9FD" "D98E32"
    # Bright: Black Red Green Yellow Blue Magenta Cyan White
    "4B7EB0" "FF5C5C" "50FA7B" "D98E32" "8BE9FD" "8BE9FD" "8BE9FD" "D98E32"
  ];
}
