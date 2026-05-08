{ config, pkgs, ... }:

{
  # NOTE: Shell (nushell) and prompt (starship) are configured per-user
  # via home-manager in hosts/lattice/home.nix

  # System-wide Terminal Configuration (Alacritty)
  environment.etc."alacritty/alacritty.toml".text = ''
    [window]
    padding = { x = 10, y = 10 }
    dynamic_title = true
    opacity = 0.95

    [font]
    normal = { family = "Cascadia Code", style = "Regular" }
    bold = { family = "Cascadia Code", style = "Bold" }
    italic = { family = "Cascadia Code", style = "Italic" }
    size = 12.0

    [colors.primary]
    background = "#000027"
    foreground = "#D98E32"

    [colors.cursor]
    text = "#000027"
    cursor = "#D98E32"

    [colors.selection]
    text = "#000027"
    background = "#4B7EB0"

    [colors.normal]
    black = "#000027"
    red = "#FF5C5C"
    green = "#50FA7B"
    yellow = "#D98E32"
    blue = "#4B7EB0"
    magenta = "#4B7EB0"
    cyan = "#8BE9FD"
    white = "#D98E32"

    [colors.bright]
    black = "#4B7EB0"
    red = "#FF5C5C"
    green = "#50FA7B"
    yellow = "#D98E32"
    blue = "#8BE9FD"
    magenta = "#8BE9FD"
    cyan = "#8BE9FD"
    white = "#D98E32"
  '';

  # WezTerm Configuration
  environment.etc."wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm'
    return {
      font = wezterm.font 'Cascadia Code',
      font_size = 12.0,
      window_background_opacity = 0.95,
      colors = {
        foreground = "#D98E32",
        background = "#000027",
        cursor_bg = "#D98E32",
        cursor_fg = "#000027",
        selection_bg = "#4B7EB0",
        selection_fg = "#000027",
        ansi = {
          "#000027", "#FF5C5C", "#50FA7B", "#D98E32", "#4B7EB0", "#4B7EB0", "#8BE9FD", "#D98E32"
        },
        brights = {
          "#4B7EB0", "#FF5C5C", "#50FA7B", "#D98E32", "#8BE9FD", "#8BE9FD", "#8BE9FD", "#D98E32"
        },
      }
    }
  '';

  # Rio Configuration
  environment.etc."rio/config.toml".text = ''
    style = { font = "Cascadia Code", size = 18 }
    [colors]
    background = '#000027'
    foreground = '#D98E32'
    cursor = '#D98E32'
    selection-background = '#4B7EB0'
    selection-foreground = '#000027'
    [colors.regular]
    black = '#000027'
    red = '#FF5C5C'
    green = '#50FA7B'
    yellow = '#D98E32'
    blue = '#4B7EB0'
    magenta = '#4B7EB0'
    cyan = '#8BE9FD'
    white = '#D98E32'
  '';

  # Steelbore System Bar (Ironbar)
  environment.etc."ironbar/config.yaml".text = ''
    anchor_to_edges: true
    position: top
    start:
      - type: workspaces
      - type: focused
    center:
      - type: clock
        format: "%H:%M:%S :: %Y-%m-%d"
    end:
      - type: sys_info
        interval: 1
        format: "CPU: {cpu_percent}% | RAM: {memory_percent}%"
      - type: tray
  '';

  environment.etc."ironbar/style.css".text = ''
    * {
        font-family: "Share Tech Mono", monospace;
        font-size: 14px;
        transition: none;
    }

    window {
        background-color: #000027;
        color: #D98E32;
        border-bottom: 2px solid #4B7EB0;
    }

    .widget {
        padding: 0 10px;
        border-left: 1px solid #4B7EB0;
    }

    .workspaces button {
        color: #4B7EB0;
        border-bottom: 2px solid transparent;
    }

    .workspaces button.active {
        color: #D98E32;
        border-bottom: 2px solid #D98E32;
    }

    .workspaces button:hover {
        background-color: #4B7EB0;
        color: #000027;
    }

    .clock {
        color: #D98E32;
        font-weight: bold;
    }

    .sys_info {
        color: #50FA7B; /* Radium Green for status */
    }
  '';

  # Git defaults
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      core.editor = "${pkgs.msedit}/bin/edit";
      color.ui = true;
    };
  };

  # Services
  services.flatpak.enable = true;

  # Security
  security.sudo.enable = false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };
}
