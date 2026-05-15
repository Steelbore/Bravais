# SPDX-License-Identifier: GPL-3.0-or-later
# Spacecraft Software Bravais — Terminal Emulators (All with Spacecraft Software Theme)
{ config, lib, pkgs, spacecraftPalette, ... }:

let
  # Foot requires hex colors without the '#' prefix
  h = c: builtins.substring 1 (builtins.stringLength c - 1) c;
in

{
  options.spacecraft.packages.terminals = {
    enable = lib.mkEnableOption "Terminal emulators";
  };

  config = lib.mkIf config.spacecraft.packages.terminals.enable {
    environment.systemPackages = with pkgs; [
      # Rust-based (preferred)
      alacritty
      wezterm
      rio
      ghostty                    # Zig, but memory-safe

      # Other terminals
      ptyxis                     # GNOME terminal (VTE-based)
      waveterm                   # AI-native terminal
      warp-terminal              # AI-powered terminal
      termius                    # SSH client
      cosmic-term                # COSMIC terminal

      # KDE terminals
      kdePackages.konsole        # KDE terminal emulator
      kdePackages.yakuake        # KDE drop-down terminal

      # GNOME terminals
      gnome-console              # GNOME Console (kgx)

      # Wayland/X11 terminals
      foot                       # Wayland terminal (C, lightweight)
      xterm                      # Classic X11 terminal

      # XFCE terminal — top-level on unstable, under `xfce.` on stable.
      # `or`-fallback evaluates clean on both channels.
      (pkgs.xfce4-terminal or pkgs.xfce.xfce4-terminal)
    ];

    # ═══════════════════════════════════════════════════════════════════════════
    # ALACRITTY — Rust-based GPU-accelerated terminal
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."alacritty/alacritty.toml".text = ''
      # Spacecraft Software Alacritty Configuration

      [window]
      padding = { x = 10, y = 10 }
      dynamic_title = true
      opacity = 0.95
      decorations = "full"

      [font]
      normal = { family = "JetBrains Mono", style = "Regular" }
      bold = { family = "JetBrains Mono", style = "Bold" }
      italic = { family = "JetBrains Mono", style = "Italic" }
      size = 10.0

      [colors.primary]
      background = "${spacecraftPalette.voidNavy}"
      foreground = "${spacecraftPalette.moltenAmber}"

      [colors.cursor]
      text = "${spacecraftPalette.voidNavy}"
      cursor = "${spacecraftPalette.moltenAmber}"

      [colors.vi_mode_cursor]
      text = "${spacecraftPalette.voidNavy}"
      cursor = "${spacecraftPalette.radiumGreen}"

      [colors.selection]
      text = "${spacecraftPalette.voidNavy}"
      background = "${spacecraftPalette.steelBlue}"

      [colors.search.matches]
      foreground = "${spacecraftPalette.voidNavy}"
      background = "${spacecraftPalette.liquidCool}"

      [colors.search.focused_match]
      foreground = "${spacecraftPalette.voidNavy}"
      background = "${spacecraftPalette.radiumGreen}"

      [colors.normal]
      black = "${spacecraftPalette.voidNavy}"
      red = "${spacecraftPalette.redOxide}"
      green = "${spacecraftPalette.radiumGreen}"
      yellow = "${spacecraftPalette.moltenAmber}"
      blue = "${spacecraftPalette.steelBlue}"
      magenta = "${spacecraftPalette.steelBlue}"
      cyan = "${spacecraftPalette.liquidCool}"
      white = "${spacecraftPalette.moltenAmber}"

      [colors.bright]
      black = "${spacecraftPalette.steelBlue}"
      red = "${spacecraftPalette.redOxide}"
      green = "${spacecraftPalette.radiumGreen}"
      yellow = "${spacecraftPalette.moltenAmber}"
      blue = "${spacecraftPalette.liquidCool}"
      magenta = "${spacecraftPalette.liquidCool}"
      cyan = "${spacecraftPalette.liquidCool}"
      white = "${spacecraftPalette.moltenAmber}"

      [terminal.shell]
      program = "${pkgs.nushell}/bin/nu"
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # WEZTERM — Rust-based GPU-accelerated terminal with Lua config
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."wezterm/wezterm.lua".text = ''
      -- Spacecraft Software WezTerm Configuration
      local wezterm = require 'wezterm'
      local config = {}

      -- Font configuration
      config.font = wezterm.font 'JetBrains Mono'
      config.font_size = 12.0

      -- Window configuration
      config.window_background_opacity = 0.95
      config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.default_prog = { "${pkgs.nushell}/bin/nu" }

      -- Spacecraft Software color scheme
      config.colors = {
        foreground = "${spacecraftPalette.moltenAmber}",
        background = "${spacecraftPalette.voidNavy}",
        cursor_bg = "${spacecraftPalette.moltenAmber}",
        cursor_fg = "${spacecraftPalette.voidNavy}",
        cursor_border = "${spacecraftPalette.moltenAmber}",
        selection_bg = "${spacecraftPalette.steelBlue}",
        selection_fg = "${spacecraftPalette.voidNavy}",
        scrollbar_thumb = "${spacecraftPalette.steelBlue}",
        split = "${spacecraftPalette.steelBlue}",

        ansi = {
          "${spacecraftPalette.voidNavy}",
          "${spacecraftPalette.redOxide}",
          "${spacecraftPalette.radiumGreen}",
          "${spacecraftPalette.moltenAmber}",
          "${spacecraftPalette.steelBlue}",
          "${spacecraftPalette.steelBlue}",
          "${spacecraftPalette.liquidCool}",
          "${spacecraftPalette.moltenAmber}"
        },
        brights = {
          "${spacecraftPalette.steelBlue}",
          "${spacecraftPalette.redOxide}",
          "${spacecraftPalette.radiumGreen}",
          "${spacecraftPalette.moltenAmber}",
          "${spacecraftPalette.liquidCool}",
          "${spacecraftPalette.liquidCool}",
          "${spacecraftPalette.liquidCool}",
          "${spacecraftPalette.moltenAmber}"
        },

        tab_bar = {
          background = "${spacecraftPalette.voidNavy}",
          active_tab = {
            bg_color = "${spacecraftPalette.steelBlue}",
            fg_color = "${spacecraftPalette.moltenAmber}",
          },
          inactive_tab = {
            bg_color = "${spacecraftPalette.voidNavy}",
            fg_color = "${spacecraftPalette.steelBlue}",
          },
          inactive_tab_hover = {
            bg_color = "${spacecraftPalette.steelBlue}",
            fg_color = "${spacecraftPalette.moltenAmber}",
          },
          new_tab = {
            bg_color = "${spacecraftPalette.voidNavy}",
            fg_color = "${spacecraftPalette.steelBlue}",
          },
          new_tab_hover = {
            bg_color = "${spacecraftPalette.steelBlue}",
            fg_color = "${spacecraftPalette.moltenAmber}",
          },
        },
      }

      return config
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # RIO — Rust-based terminal with native GPU rendering
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."rio/config.toml".text = ''
      # Spacecraft Software Rio Configuration

      [window]
      opacity = 0.95
      decorations = "enabled"

      [fonts]
      size = 14

      [fonts.regular]
      family = "JetBrains Mono"
      weight = 400

      [fonts.bold]
      family = "JetBrains Mono"
      weight = 700

      [fonts.italic]
      family = "JetBrains Mono"
      weight = 400

      [fonts.bold-italic]
      family = "JetBrains Mono"
      weight = 700

      [colors]
      background = '${spacecraftPalette.voidNavy}'
      foreground = '${spacecraftPalette.moltenAmber}'
      cursor = '${spacecraftPalette.moltenAmber}'
      tabs = '${spacecraftPalette.steelBlue}'
      tabs-active = '${spacecraftPalette.moltenAmber}'
      selection-background = '${spacecraftPalette.steelBlue}'
      selection-foreground = '${spacecraftPalette.voidNavy}'

      [colors.regular]
      black = '${spacecraftPalette.voidNavy}'
      red = '${spacecraftPalette.redOxide}'
      green = '${spacecraftPalette.radiumGreen}'
      yellow = '${spacecraftPalette.moltenAmber}'
      blue = '${spacecraftPalette.steelBlue}'
      magenta = '${spacecraftPalette.steelBlue}'
      cyan = '${spacecraftPalette.liquidCool}'
      white = '${spacecraftPalette.moltenAmber}'

      [colors.bright]
      black = '${spacecraftPalette.steelBlue}'
      red = '${spacecraftPalette.redOxide}'
      green = '${spacecraftPalette.radiumGreen}'
      yellow = '${spacecraftPalette.moltenAmber}'
      blue = '${spacecraftPalette.liquidCool}'
      magenta = '${spacecraftPalette.liquidCool}'
      cyan = '${spacecraftPalette.liquidCool}'
      white = '${spacecraftPalette.moltenAmber}'

      [shell]
      program = "${pkgs.nushell}/bin/nu"
      args = []
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # GHOSTTY — Zig-based GPU-accelerated terminal (memory-safe)
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."ghostty/config".text = ''
      # Spacecraft Software Ghostty Configuration

      font-family = JetBrains Mono
      font-size = 12

      background-opacity = 0.95
      window-padding-x = 10
      window-padding-y = 10

      # Spacecraft Software color palette
      background = ${spacecraftPalette.voidNavy}
      foreground = ${spacecraftPalette.moltenAmber}
      cursor-color = ${spacecraftPalette.moltenAmber}
      cursor-text = ${spacecraftPalette.voidNavy}
      selection-background = ${spacecraftPalette.steelBlue}
      selection-foreground = ${spacecraftPalette.voidNavy}

      # Normal colors (0-7)
      palette = 0=${spacecraftPalette.voidNavy}
      palette = 1=${spacecraftPalette.redOxide}
      palette = 2=${spacecraftPalette.radiumGreen}
      palette = 3=${spacecraftPalette.moltenAmber}
      palette = 4=${spacecraftPalette.steelBlue}
      palette = 5=${spacecraftPalette.steelBlue}
      palette = 6=${spacecraftPalette.liquidCool}
      palette = 7=${spacecraftPalette.moltenAmber}

      # Bright colors (8-15)
      palette = 8=${spacecraftPalette.steelBlue}
      palette = 9=${spacecraftPalette.redOxide}
      palette = 10=${spacecraftPalette.radiumGreen}
      palette = 11=${spacecraftPalette.moltenAmber}
      palette = 12=${spacecraftPalette.liquidCool}
      palette = 13=${spacecraftPalette.liquidCool}
      palette = 14=${spacecraftPalette.liquidCool}
      palette = 15=${spacecraftPalette.moltenAmber}

      # Shell — launches ion
      command = ${pkgs.nushell}/bin/nu
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # COSMIC-TERM — COSMIC desktop terminal (Rust-based)
    # Config is typically managed by cosmic-settings, but we provide defaults
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."cosmic/com.system76.CosmicTerm/v1/syntax_theme_dark".text = ''
      "Spacecraft Software"
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # PTYXIS (GNOME Console) — VTE-based terminal
    # Uses dconf/gsettings, configured via GNOME module or home-manager
    # Providing a CSS override for theming
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."gtk-4.0/gtk.css".text = ''
      /* Spacecraft Software Ptyxis/VTE Terminal Theme Override */
      vte-terminal {
        padding: 10px;
      }
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # WAVETERM — AI-native terminal
    # Uses JSON configuration
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."waveterm/config.json".text = builtins.toJSON {
      term = {
        fontfamily = "JetBrains Mono";
        fontsize = 12;
        theme = "custom";
      };
      themes = {
        custom = {
          display = {
            name = "Spacecraft Software";
            order = 1;
          };
          terminal = {
            background = spacecraftPalette.voidNavy;
            foreground = spacecraftPalette.moltenAmber;
            cursor = spacecraftPalette.moltenAmber;
            selectionBackground = spacecraftPalette.steelBlue;
            black = spacecraftPalette.voidNavy;
            red = spacecraftPalette.redOxide;
            green = spacecraftPalette.radiumGreen;
            yellow = spacecraftPalette.moltenAmber;
            blue = spacecraftPalette.steelBlue;
            magenta = spacecraftPalette.steelBlue;
            cyan = spacecraftPalette.liquidCool;
            white = spacecraftPalette.moltenAmber;
            brightBlack = spacecraftPalette.steelBlue;
            brightRed = spacecraftPalette.redOxide;
            brightGreen = spacecraftPalette.radiumGreen;
            brightYellow = spacecraftPalette.moltenAmber;
            brightBlue = spacecraftPalette.liquidCool;
            brightMagenta = spacecraftPalette.liquidCool;
            brightCyan = spacecraftPalette.liquidCool;
            brightWhite = spacecraftPalette.moltenAmber;
          };
        };
      };
    };

    # ═══════════════════════════════════════════════════════════════════════════
    # WARP TERMINAL — AI-powered terminal
    # Uses YAML configuration
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."warp/themes/spacecraft.yaml".text = ''
      # Spacecraft Software Theme for Warp Terminal
      accent: '${spacecraftPalette.steelBlue}'
      background: '${spacecraftPalette.voidNavy}'
      foreground: '${spacecraftPalette.moltenAmber}'
      details: darker
      terminal_colors:
        normal:
          black: '${spacecraftPalette.voidNavy}'
          red: '${spacecraftPalette.redOxide}'
          green: '${spacecraftPalette.radiumGreen}'
          yellow: '${spacecraftPalette.moltenAmber}'
          blue: '${spacecraftPalette.steelBlue}'
          magenta: '${spacecraftPalette.steelBlue}'
          cyan: '${spacecraftPalette.liquidCool}'
          white: '${spacecraftPalette.moltenAmber}'
        bright:
          black: '${spacecraftPalette.steelBlue}'
          red: '${spacecraftPalette.redOxide}'
          green: '${spacecraftPalette.radiumGreen}'
          yellow: '${spacecraftPalette.moltenAmber}'
          blue: '${spacecraftPalette.liquidCool}'
          magenta: '${spacecraftPalette.liquidCool}'
          cyan: '${spacecraftPalette.liquidCool}'
          white: '${spacecraftPalette.moltenAmber}'
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # TERMIUS — SSH client (theming limited, uses app settings)
    # No system-level theming available; users configure in-app
    # ═══════════════════════════════════════════════════════════════════════════

    # ═══════════════════════════════════════════════════════════════════════════
    # KONSOLE — KDE terminal emulator
    # Colorscheme + profile placed in system XDG data dir
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."xdg/konsole/Spacecraft Software.colorscheme".text = ''
      # Spacecraft Software Konsole Color Scheme
      # Palette: Void Navy / Molten Amber / Steel Blue / Radium Green / Red Oxide / Liquid Coolant

      [Background]
      Color=0,0,39

      [BackgroundFaint]
      Color=0,0,39

      [BackgroundIntense]
      Bold=true
      Color=75,126,176

      [Color0]
      Color=0,0,39

      [Color0Faint]
      Color=0,0,39

      [Color0Intense]
      Bold=true
      Color=75,126,176

      [Color1]
      Color=255,92,92

      [Color1Faint]
      Color=255,92,92

      [Color1Intense]
      Bold=true
      Color=255,92,92

      [Color2]
      Color=80,250,123

      [Color2Faint]
      Color=80,250,123

      [Color2Intense]
      Bold=true
      Color=80,250,123

      [Color3]
      Color=217,142,50

      [Color3Faint]
      Color=217,142,50

      [Color3Intense]
      Bold=true
      Color=217,142,50

      [Color4]
      Color=75,126,176

      [Color4Faint]
      Color=75,126,176

      [Color4Intense]
      Bold=true
      Color=139,233,253

      [Color5]
      Color=75,126,176

      [Color5Faint]
      Color=75,126,176

      [Color5Intense]
      Bold=true
      Color=139,233,253

      [Color6]
      Color=139,233,253

      [Color6Faint]
      Color=139,233,253

      [Color6Intense]
      Bold=true
      Color=139,233,253

      [Color7]
      Color=217,142,50

      [Color7Faint]
      Color=217,142,50

      [Color7Intense]
      Bold=true
      Color=217,142,50

      [Foreground]
      Color=217,142,50

      [ForegroundFaint]
      Color=217,142,50

      [ForegroundIntense]
      Bold=true
      Color=217,142,50

      [General]
      Anchor=0.5,0.5
      Blur=false
      ColorRandomization=false
      Description=Spacecraft Software
      FillStyle=Tile
      Opacity=0.95
      Spread=1.0
      Wallpaper=
    '';

    environment.etc."xdg/konsole/Spacecraft Software.profile".text = ''
      # Spacecraft Software Konsole Profile

      [Appearance]
      ColorScheme=Spacecraft Software
      Font=JetBrains Mono,12,-1,5,50,0,0,0,0,0

      [General]
      Command=${pkgs.nushell}/bin/nu
      Name=Spacecraft Software
      Parent=FALLBACK/
      TerminalColumns=160
      TerminalRows=48

      [Scrolling]
      HistoryMode=2
      ScrollFullPage=false

      [Terminal Features]
      BlinkingCursorEnabled=true
    '';

    environment.etc."xdg/konsolerc".text = ''
      [Desktop Entry]
      DefaultProfile=Spacecraft Software.profile

      [TabBar]
      CloseTabOnMiddleMouseButton=true
      NewTabButton=false
      TabBarPosition=Top
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # YAKUAKE — KDE drop-down terminal (uses Konsole as backend)
    # Shell and colors are inherited from the Konsole Spacecraft Software profile above
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."xdg/yakuakerc".text = ''
      [Desktop Entry]
      DefaultProfile=Spacecraft Software.profile

      [Window]
      Height=50
      Width=100
      KeepOpen=false
      AnimationDuration=0
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # FOOT — Wayland terminal (C, lightweight)
    # System-level fallback config at /etc/xdg/foot/foot.ini
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."xdg/foot/foot.ini".text = ''
      # Spacecraft Software Foot Configuration

      [main]
      font=JetBrains Mono:size=12
      shell=${pkgs.nushell}/bin/nu
      term=xterm-256color

      [colors]
      background=${h spacecraftPalette.voidNavy}
      foreground=${h spacecraftPalette.moltenAmber}
      regular0=${h spacecraftPalette.voidNavy}
      regular1=${h spacecraftPalette.redOxide}
      regular2=${h spacecraftPalette.radiumGreen}
      regular3=${h spacecraftPalette.moltenAmber}
      regular4=${h spacecraftPalette.steelBlue}
      regular5=${h spacecraftPalette.steelBlue}
      regular6=${h spacecraftPalette.liquidCool}
      regular7=${h spacecraftPalette.moltenAmber}
      bright0=${h spacecraftPalette.steelBlue}
      bright1=${h spacecraftPalette.redOxide}
      bright2=${h spacecraftPalette.radiumGreen}
      bright3=${h spacecraftPalette.moltenAmber}
      bright4=${h spacecraftPalette.liquidCool}
      bright5=${h spacecraftPalette.liquidCool}
      bright6=${h spacecraftPalette.liquidCool}
      bright7=${h spacecraftPalette.moltenAmber}
      cursor=${h spacecraftPalette.voidNavy} ${h spacecraftPalette.moltenAmber}
      selection-foreground=${h spacecraftPalette.voidNavy}
      selection-background=${h spacecraftPalette.steelBlue}

      [scrollback]
      lines=10000
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # XTERM — Classic X11 terminal
    # System-level Xresources loaded by xrdb on X session start
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."X11/Xresources".text = ''
      ! Spacecraft Software XTerm Configuration

      XTerm*termName:              xterm-256color
      XTerm*faceName:              JetBrains Mono
      XTerm*faceSize:              12
      XTerm*loginShell:            true
      XTerm*scrollBar:             false
      XTerm*saveLines:             10000
      XTerm*bellIsUrgent:          true
      XTerm*internalBorder:        10

      XTerm*background:            ${spacecraftPalette.voidNavy}
      XTerm*foreground:            ${spacecraftPalette.moltenAmber}
      XTerm*cursorColor:           ${spacecraftPalette.moltenAmber}
      XTerm*pointerColorBackground:${spacecraftPalette.voidNavy}
      XTerm*pointerColorForeground:${spacecraftPalette.moltenAmber}
      XTerm*highlightColor:        ${spacecraftPalette.steelBlue}

      XTerm*color0:                ${spacecraftPalette.voidNavy}
      XTerm*color1:                ${spacecraftPalette.redOxide}
      XTerm*color2:                ${spacecraftPalette.radiumGreen}
      XTerm*color3:                ${spacecraftPalette.moltenAmber}
      XTerm*color4:                ${spacecraftPalette.steelBlue}
      XTerm*color5:                ${spacecraftPalette.steelBlue}
      XTerm*color6:                ${spacecraftPalette.liquidCool}
      XTerm*color7:                ${spacecraftPalette.moltenAmber}
      XTerm*color8:                ${spacecraftPalette.steelBlue}
      XTerm*color9:                ${spacecraftPalette.redOxide}
      XTerm*color10:               ${spacecraftPalette.radiumGreen}
      XTerm*color11:               ${spacecraftPalette.moltenAmber}
      XTerm*color12:               ${spacecraftPalette.liquidCool}
      XTerm*color13:               ${spacecraftPalette.liquidCool}
      XTerm*color14:               ${spacecraftPalette.liquidCool}
      XTerm*color15:               ${spacecraftPalette.moltenAmber}
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # XFCE4-TERMINAL — XFCE4 terminal
    # System-level fallback config
    # ═══════════════════════════════════════════════════════════════════════════
    environment.etc."xdg/xfce4/terminal/terminalrc".text = ''
      [Configuration]
      FontName=JetBrains Mono 12
      MiscDefaultGeometry=160x48
      RunCustomCommand=TRUE
      CustomCommand=${pkgs.nushell}/bin/nu
      BackgroundMode=TERMINAL_BACKGROUND_TRANSPARENT
      BackgroundDarkness=0.95
      ColorBackground=${spacecraftPalette.voidNavy}
      ColorForeground=${spacecraftPalette.moltenAmber}
      ColorCursor=${spacecraftPalette.moltenAmber}
      ColorBold=FALSE
      ColorPalette=${spacecraftPalette.voidNavy};${spacecraftPalette.redOxide};${spacecraftPalette.radiumGreen};${spacecraftPalette.moltenAmber};${spacecraftPalette.steelBlue};${spacecraftPalette.steelBlue};${spacecraftPalette.liquidCool};${spacecraftPalette.moltenAmber};${spacecraftPalette.steelBlue};${spacecraftPalette.redOxide};${spacecraftPalette.radiumGreen};${spacecraftPalette.moltenAmber};${spacecraftPalette.liquidCool};${spacecraftPalette.liquidCool};${spacecraftPalette.liquidCool};${spacecraftPalette.moltenAmber}
      MiscMenubarDefault=FALSE
      ScrollingBar=TERMINAL_SCROLLBAR_NONE
      ScrollingLines=10000
    '';

    # ═══════════════════════════════════════════════════════════════════════════
    # GNOME CONSOLE (kgx) — GNOME 4x minimal terminal
    # Color palette is fixed by theme; "night" is the closest dark option.
    # Shell is inherited from $SHELL (ion). Configured via dconf in home.
    # ═══════════════════════════════════════════════════════════════════════════
  };
}
