# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Library Functions
{ lib, ... }:

{
  # Spacecraft Software color palette for use across modules
  spacecraftPalette = {
    voidNavy     = "#000027";
    moltenAmber  = "#D98E32";
    steelBlue    = "#4B7EB0";
    radiumGreen  = "#50FA7B";
    redOxide     = "#FF5C5C";
    liquidCool   = "#8BE9FD";
  };

  # Helper to create a Spacecraft Software module with standard options
  mkSpacecraftModule = { name, description, config }: {
    options.spacecraft.${name} = {
      enable = lib.mkEnableOption description;
    };

    config = lib.mkIf config.spacecraft.${name}.enable config;
  };
}
