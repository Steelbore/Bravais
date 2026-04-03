# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Typography Configuration
{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # UI Headers
    orbitron

    # Code / Terminal
    jetbrains-mono

    # Nerd Fonts (icons)
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-mono

    # HUD / Data Display
    (stdenv.mkDerivation {
      pname = "share-tech-mono";
      version = "1.0";
      src = fetchurl {
        url = "https://github.com/google/fonts/raw/main/ofl/sharetechmono/ShareTechMono-Regular.ttf";
        hash = "sha256-0xr6ffvbx8516rxb5h2767fzfgp079bkgxf0b7r9m0hlfkwb3slw";
      };
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp $src $out/share/fonts/truetype/ShareTechMono-Regular.ttf
      '';
    })
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrains Mono" "CaskaydiaMono Nerd Font" "Share Tech Mono" ];
    sansSerif = [ "Orbitron" ];
    serif = [ "Orbitron" ];
  };
}
