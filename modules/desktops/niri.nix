# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Niri Scrolling Tiling Compositor (Wayland)
{ config, lib, pkgs, steelborePalette, ... }:

{
  options.steelbore.desktops.niri = {
    enable = lib.mkEnableOption "Niri scrolling tiling compositor (Wayland)";
  };

  config = lib.mkIf config.steelbore.desktops.niri.enable {
    # Enable Niri
    programs.niri.enable = true;

    # Niri and companion packages
    environment.systemPackages = with pkgs; [
      niri
      swaybg                    # Background
      xwayland-satellite        # X11 app support
      ironbar                   # Status bar (Rust)
      waybar                    # Alternative bar
      anyrun                    # Application launcher (Rust)
      onagre                    # Application launcher (Rust)
      wired                     # Notification daemon (Rust)
      swaylock                  # Screen locker
      swayidle                  # Idle management
      wl-clipboard              # Clipboard
      wl-clipboard-rs           # Clipboard (Rust)
      grim                      # Screenshot
      slurp                     # Region selection
    ];

    # System-wide Niri configuration
    environment.etc."niri/config.kdl".text = ''
      // Steelbore Niri Configuration
      // The Steelbore Standard — Scrolling Tiling

      layout {
          gaps 8

          focus-ring {
              enable
              width 2
              active-color "${steelborePalette.moltenAmber}"
              inactive-color "${steelborePalette.steelBlue}"
          }

          border {
              off
              width 1
              active-color "${steelborePalette.moltenAmber}"
              inactive-color "${steelborePalette.steelBlue}"
          }

          // Default column width
          default-column-width { proportion 0.5; }

          // Center focused column when it changes
          center-focused-column "on-overflow"
      }

      // Startup applications
      spawn-at-startup "swaybg" "-c" "${steelborePalette.voidNavy}"
      spawn-at-startup "ironbar"
      spawn-at-startup "wired"

      // Input configuration
      input {
          keyboard {
              xkb {
                  layout "us,ar"
                  options "grp:ctrl_space_toggle"
              }
          }

          touchpad {
              tap
              natural-scroll
              accel-speed 0.3
          }
      }

      // Key bindings
      binds {
          // Session
          Mod+Shift+E { quit; }
          Mod+Shift+L { spawn "swaylock" "-c" "${steelborePalette.voidNavy}"; }

          // Applications
          Mod+Return { spawn "rio"; }
          Mod+D { spawn "onagre"; }
          Mod+Shift+D { spawn "anyrun"; }

          // Window management
          Mod+Q { close-window; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }

          // Focus
          Mod+Left  { focus-column-left; }
          Mod+Right { focus-column-right; }
          Mod+Up    { focus-window-up; }
          Mod+Down  { focus-window-down; }
          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+K { focus-window-up; }
          Mod+J { focus-window-down; }

          // Move windows
          Mod+Shift+Left  { move-column-left; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+Up    { move-window-up; }
          Mod+Shift+Down  { move-window-down; }
          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
          Mod+Shift+K { move-window-up; }
          Mod+Shift+J { move-window-down; }

          // Workspaces
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+Shift+1 { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }

          // Resize
          Mod+R { switch-preset-column-width; }
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }

          // Screenshots
          Print { screenshot; }
          Mod+Print { screenshot-window; }
          Mod+Shift+Print { screenshot-screen; }
      }
    '';

    # Ironbar configuration (Steelbore Status Bar)
    environment.etc."ironbar/config.yaml".text = ''
      # Steelbore Ironbar Configuration
      anchor_to_edges: true
      position: top
      height: 32

      start:
        - type: workspaces
        - type: focused

      center:
        - type: clock
          format: "%H:%M:%S :: %Y-%m-%d"

      end:
        - type: sys_info
          interval: 1
          format:
            - "CPU: {cpu_percent}%"
            - "RAM: {memory_percent}%"
        - type: tray
    '';

    environment.etc."ironbar/style.css".text = ''
      /* Steelbore Ironbar Theme */
      * {
          font-family: "Share Tech Mono", "JetBrains Mono", monospace;
          font-size: 14px;
          transition: none;
      }

      window {
          background-color: ${steelborePalette.voidNavy};
          color: ${steelborePalette.moltenAmber};
          border-bottom: 2px solid ${steelborePalette.steelBlue};
      }

      .widget {
          padding: 0 10px;
          border-left: 1px solid ${steelborePalette.steelBlue};
      }

      .workspaces button {
          color: ${steelborePalette.steelBlue};
          border-bottom: 2px solid transparent;
          padding: 0 8px;
      }

      .workspaces button.active {
          color: ${steelborePalette.moltenAmber};
          border-bottom: 2px solid ${steelborePalette.moltenAmber};
      }

      .workspaces button:hover {
          background-color: ${steelborePalette.steelBlue};
          color: ${steelborePalette.voidNavy};
      }

      .focused {
          color: ${steelborePalette.liquidCool};
      }

      .clock {
          color: ${steelborePalette.moltenAmber};
          font-weight: bold;
      }

      .sys_info {
          color: ${steelborePalette.radiumGreen};
      }

      .tray {
          padding: 0 5px;
      }
    '';
  };
}
