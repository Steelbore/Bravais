# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Niri Scrolling Tiling Compositor (Wayland)
{ config, lib, pkgs, steelborePalette, ... }:

{
  options.steelbore.desktops.niri = {
    enable = lib.mkEnableOption "Niri scrolling tiling compositor (Wayland)";
  };

  config = lib.mkIf config.steelbore.desktops.niri.enable {
    # Enable Niri
    programs.niri.enable = true;

    # Niri and companion packages.
    # Stack matches LeftWM where cross-platform (eww, dunst, gtklock) and
    # uses Wayland-only tools where the X11 alternatives don't exist.
    environment.systemPackages = with pkgs; [
      niri
      xwayland-satellite        # X11 app support inside Niri

      # Status bar — Eww (Rust, X11 + Wayland; shared with LeftWM)
      eww

      # Launcher — Anyrun (Rust, Wayland)
      anyrun

      # Notifications — dunst (cross-platform with LeftWM)
      dunst

      # Wallpaper daemon — swww (Rust, Wayland; uses `swww clear` for solid)
      swww

      # Screen locker — gtklock (cross-platform with LeftWM)
      gtklock
      swayidle                  # Idle management

      # Clipboard / screenshot
      wl-clipboard
      wl-clipboard-rs           # (Rust)
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

      // Startup applications.
      // swww needs the daemon up before any swww command; the inline sleep
      // gives the daemon a moment to bind its IPC socket before `swww clear`
      // sets the solid Void Navy wallpaper. Eww and dunst start in parallel.
      spawn-at-startup "swww-daemon"
      spawn-at-startup "sh" "-c" "sleep 1 && swww clear ${lib.removePrefix "#" steelborePalette.voidNavy}"
      spawn-at-startup "eww" "open" "bar"
      spawn-at-startup "dunst"

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
          Mod+Shift+L { spawn "gtklock"; }

          // Applications
          Mod+Return { spawn "rio"; }
          Mod+D { spawn "anyrun"; }

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

    # Status bar / launcher / notifications / wallpaper / lock are now
    # configured at the home-manager level. Eww config lives in
    # users/mj/home.nix (xdg.configFile."eww/..."); dunst remains at
    # /etc/dunst/dunstrc (set in modules/desktops/leftwm.nix).
  };
}
