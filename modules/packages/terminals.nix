# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Terminal Emulators
{ config, lib, pkgs, steelborePalette, ... }:

{
  options.steelbore.packages.terminals = {
    enable = lib.mkEnableOption "Terminal emulators";
  };

  config = lib.mkIf config.steelbore.packages.terminals.enable {
    environment.systemPackages = with pkgs; [
      # Rust-based (preferred)
      alacritty
      wezterm
      rio
      ghostty                    # Zig, but memory-safe

      # Other terminals
      ptyxis                     # GNOME terminal
      waveterm                   # AI-native terminal
      warp-terminal              # AI-powered terminal
      termius                    # SSH client
      cosmic-term                # COSMIC terminal
    ];

    # Alacritty configuration (Steelbore theme)
    environment.etc."alacritty/alacritty.toml".text = ''
      [window]
      padding = { x = 10, y = 10 }
      dynamic_title = true
      opacity = 0.95

      [font]
      normal = { family = "JetBrains Mono", style = "Regular" }
      bold = { family = "JetBrains Mono", style = "Bold" }
      italic = { family = "JetBrains Mono", style = "Italic" }
      size = 12.0

      [colors.primary]
      background = "${steelborePalette.voidNavy}"
      foreground = "${steelborePalette.moltenAmber}"

      [colors.cursor]
      text = "${steelborePalette.voidNavy}"
      cursor = "${steelborePalette.moltenAmber}"

      [colors.selection]
      text = "${steelborePalette.voidNavy}"
      background = "${steelborePalette.steelBlue}"

      [colors.normal]
      black = "${steelborePalette.voidNavy}"
      red = "${steelborePalette.redOxide}"
      green = "${steelborePalette.radiumGreen}"
      yellow = "${steelborePalette.moltenAmber}"
      blue = "${steelborePalette.steelBlue}"
      magenta = "${steelborePalette.steelBlue}"
      cyan = "${steelborePalette.liquidCool}"
      white = "${steelborePalette.moltenAmber}"

      [colors.bright]
      black = "${steelborePalette.steelBlue}"
      red = "${steelborePalette.redOxide}"
      green = "${steelborePalette.radiumGreen}"
      yellow = "${steelborePalette.moltenAmber}"
      blue = "${steelborePalette.liquidCool}"
      magenta = "${steelborePalette.liquidCool}"
      cyan = "${steelborePalette.liquidCool}"
      white = "${steelborePalette.moltenAmber}"
    '';

    # WezTerm configuration (Steelbore theme)
    environment.etc."wezterm/wezterm.lua".text = ''
      local wezterm = require 'wezterm'
      return {
        font = wezterm.font 'JetBrains Mono',
        font_size = 12.0,
        window_background_opacity = 0.95,
        colors = {
          foreground = "${steelborePalette.moltenAmber}",
          background = "${steelborePalette.voidNavy}",
          cursor_bg = "${steelborePalette.moltenAmber}",
          cursor_fg = "${steelborePalette.voidNavy}",
          selection_bg = "${steelborePalette.steelBlue}",
          selection_fg = "${steelborePalette.voidNavy}",
          ansi = {
            "${steelborePalette.voidNavy}",
            "${steelborePalette.redOxide}",
            "${steelborePalette.radiumGreen}",
            "${steelborePalette.moltenAmber}",
            "${steelborePalette.steelBlue}",
            "${steelborePalette.steelBlue}",
            "${steelborePalette.liquidCool}",
            "${steelborePalette.moltenAmber}"
          },
          brights = {
            "${steelborePalette.steelBlue}",
            "${steelborePalette.redOxide}",
            "${steelborePalette.radiumGreen}",
            "${steelborePalette.moltenAmber}",
            "${steelborePalette.liquidCool}",
            "${steelborePalette.liquidCool}",
            "${steelborePalette.liquidCool}",
            "${steelborePalette.moltenAmber}"
          },
        }
      }
    '';

    # Rio configuration (Steelbore theme)
    environment.etc."rio/config.toml".text = ''
      [style]
      font = "JetBrains Mono"
      font-size = 14

      [colors]
      background = '${steelborePalette.voidNavy}'
      foreground = '${steelborePalette.moltenAmber}'
      cursor = '${steelborePalette.moltenAmber}'
      selection-background = '${steelborePalette.steelBlue}'
      selection-foreground = '${steelborePalette.voidNavy}'

      [colors.regular]
      black = '${steelborePalette.voidNavy}'
      red = '${steelborePalette.redOxide}'
      green = '${steelborePalette.radiumGreen}'
      yellow = '${steelborePalette.moltenAmber}'
      blue = '${steelborePalette.steelBlue}'
      magenta = '${steelborePalette.steelBlue}'
      cyan = '${steelborePalette.liquidCool}'
      white = '${steelborePalette.moltenAmber}'
    '';
  };
}
