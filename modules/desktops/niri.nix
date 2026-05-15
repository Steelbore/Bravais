# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Niri Scrolling Tiling Compositor (Wayland)
{ config, lib, pkgs, spacecraftPalette, ... }:

{
  options.spacecraft.desktops.niri = {
    enable = lib.mkEnableOption "Niri scrolling tiling compositor (Wayland)";
  };

  config = lib.mkIf config.spacecraft.desktops.niri.enable (
    let
      # Wallpaper daemon: upstream renamed swww → awww. On unstable both
      # exist (swww is a deprecation alias that warns); on stable 25.11
      # only swww exists. The `or`-fallback picks the right package per
      # channel. Binary names follow the package name (awww/awww-daemon
      # vs swww/swww-daemon), so we derive `wallpaperBin` to match.
      wallpaperPkg = pkgs.awww or pkgs.swww;
      wallpaperBin = if pkgs ? awww then "awww" else "swww";
    in
    {
    # Enable Niri
    programs.niri.enable = true;

    # Niri and companion packages.
    # Stack matches LeftWM where cross-platform (eww, dunst, gtklock) and
    # uses Wayland-only tools where the X11 alternatives don't exist.
    environment.systemPackages = (with pkgs; [
      niri
      xwayland-satellite        # X11 app support inside Niri

      # Status bar — Eww (Rust, X11 + Wayland; shared with LeftWM)
      eww

      # Launcher — Anyrun (Rust, Wayland)
      anyrun

      # Notifications — dunst (cross-platform with LeftWM)
      dunst

      # Screen locker — gtklock (cross-platform with LeftWM)
      gtklock
      swayidle                  # Idle management

      # Clipboard / screenshot
      wl-clipboard
      wl-clipboard-rs           # (Rust)
      grim                      # Screenshot
      slurp                     # Region selection
    ]) ++ [
      # Wallpaper daemon — awww (renamed from swww upstream).
      wallpaperPkg
    ];

    # System-wide Niri configuration
    environment.etc."niri/config.kdl".text = ''
      // Spacecraft Software Niri Configuration
      // The Spacecraft Software Standard — Scrolling Tiling

      // Session-wide environment. Niri imports these into the systemd
      // user manager's env, which xdg-desktop-portal-* and every
      // spawn-at-startup child inherit. XDG_CURRENT_DESKTOP is what
      // xdg-desktop-portal routes on (see xdg.portal.config.niri in
      // modules/theme/dark-mode.nix).
      environment {
          XDG_CURRENT_DESKTOP "niri"
      }

      layout {
          gaps 8

          focus-ring {
              // off  — uncomment to disable; presence of the block enables it
              width 2
              active-color "${spacecraftPalette.moltenAmber}"
              inactive-color "${spacecraftPalette.steelBlue}"
          }

          border {
              off
              width 1
              active-color "${spacecraftPalette.moltenAmber}"
              inactive-color "${spacecraftPalette.steelBlue}"
          }

          // Default column width
          default-column-width { proportion 0.5; }

          // Center focused column when it changes
          center-focused-column "on-overflow"
      }

      // Startup applications.
      // The wallpaper daemon needs to bind its IPC socket before any
      // client command; the inline sleep gives it a moment before the
      // `clear` call sets the solid Void Navy wallpaper. Eww and dunst
      // start in parallel.
      spawn-at-startup "${wallpaperPkg}/bin/${wallpaperBin}-daemon"
      spawn-at-startup "sh" "-c" "sleep 1 && ${wallpaperPkg}/bin/${wallpaperBin} clear ${lib.removePrefix "#" spacecraftPalette.voidNavy}"
      spawn-at-startup "eww" "open" "bar"
      spawn-at-startup "dunst"
      // Load SSH key into gitway-agent once per session. With no TTY but
      // DISPLAY/WAYLAND_DISPLAY set, gitway-add uses $SSH_ASKPASS
      // (ksshaskpass) automatically. Cached for 24 h per the agent TTL.
      spawn-at-startup "gitway-add" "/home/mj/.ssh/id_ed25519"

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
              accel-speed 0.3
              natural-scroll
          }
      }

      // Key bindings.
      //
      // `hotkey-overlay-title="..."` populates Niri's show-hotkey-overlay
      // cheatsheet. Binds WITHOUT a title are still active but hidden
      // from the overlay — used here for secondary aliases (vim-style
      // movement that mirrors arrow-key binds, mouse-wheel workspace
      // nav, individual workspace 2-9 numbers that share the title of
      // the Mod+1 anchor entry).
      binds {
          // Session
          Mod+Shift+E hotkey-overlay-title="Exit niri" { quit; }
          Mod+Shift+L hotkey-overlay-title="Lock the Screen: gtklock" { spawn "gtklock"; }
          // `Slash` is Niri's KDL name for the `/` key (US layout produces
          // `?` when shifted) — consistent with our use of symbolic names
          // (Minus, Equal, Return) elsewhere in the bind table.
          Mod+Shift+Slash hotkey-overlay-title="Show Important Hotkeys" { show-hotkey-overlay; }

          // Applications
          Mod+Return hotkey-overlay-title="Open a Terminal: rio" { spawn "rio"; }
          Mod+D hotkey-overlay-title="Run an Application: anyrun" { spawn "anyrun"; }

          // Window management
          Mod+Q hotkey-overlay-title="Close Focused Window" { close-window; }
          Mod+F hotkey-overlay-title="Maximize Column" { maximize-column; }
          Mod+Shift+F hotkey-overlay-title="Fullscreen Window" { fullscreen-window; }

          // Floating
          Mod+V hotkey-overlay-title="Toggle Window Floating" { toggle-window-floating; }
          Mod+Shift+V hotkey-overlay-title="Switch Focus Floating/Tiling" { switch-focus-between-floating-and-tiling; }

          // Overview
          Mod+O hotkey-overlay-title="Open the Overview" { toggle-overview; }

          // Focus — arrow-key primaries appear in the overlay; vim
          // duplicates are silent secondary aliases.
          Mod+Left  hotkey-overlay-title="Focus Column to the Left"  { focus-column-left; }
          Mod+Right hotkey-overlay-title="Focus Column to the Right" { focus-column-right; }
          Mod+Up    hotkey-overlay-title="Focus Window Up"           { focus-window-up; }
          Mod+Down  hotkey-overlay-title="Focus Window Down"         { focus-window-down; }
          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+K { focus-window-up; }
          Mod+J { focus-window-down; }

          // Move windows — Mod+Ctrl+arrows primaries (matches Niri's
          // default-config idioms); Mod+Shift+arrows and vim variants
          // are silent secondary aliases for muscle memory.
          Mod+Ctrl+Left  hotkey-overlay-title="Move Column Left"   { move-column-left; }
          Mod+Ctrl+Right hotkey-overlay-title="Move Column Right"  { move-column-right; }
          Mod+Ctrl+Up    hotkey-overlay-title="Move Window Up"     { move-window-up; }
          Mod+Ctrl+Down  hotkey-overlay-title="Move Window Down"   { move-window-down; }
          Mod+Shift+Left  { move-column-left; }
          Mod+Shift+Right { move-column-right; }
          Mod+Shift+Up    { move-window-up; }
          Mod+Shift+Down  { move-window-down; }
          // Mod+Shift+L is reserved for gtklock; vim moves use H/K/J only.
          Mod+Shift+H { move-column-left; }
          Mod+Shift+K { move-window-up; }
          Mod+Shift+J { move-window-down; }

          // Consume / Expel (column-folding) — square brackets per the
          // Niri default-config idiom. `BracketLeft`/`BracketRight` are
          // Niri's KDL names for `[`/`]`.
          Mod+BracketLeft  hotkey-overlay-title="Consume Window into Column" { consume-or-expel-window-left; }
          Mod+BracketRight hotkey-overlay-title="Expel Window into New Column" { consume-or-expel-window-right; }

          // Workspaces (Mod+1 is the anchor; 2-5 share the same
          // semantic title so the overlay isn't flooded).
          Mod+1 hotkey-overlay-title="Switch to Workspace 1-5" { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+Shift+1 hotkey-overlay-title="Move Column to Workspace 1-5" { move-column-to-workspace 1; }
          Mod+Shift+2 { move-column-to-workspace 2; }
          Mod+Shift+3 { move-column-to-workspace 3; }
          Mod+Shift+4 { move-column-to-workspace 4; }
          Mod+Shift+5 { move-column-to-workspace 5; }

          // Workspace navigation (relative)
          Mod+Page_Down hotkey-overlay-title="Switch Workspace Down" { focus-workspace-down; }
          Mod+Page_Up   hotkey-overlay-title="Switch Workspace Up"   { focus-workspace-up; }
          Mod+Ctrl+Page_Down hotkey-overlay-title="Move Column to Workspace Down" { move-column-to-workspace-down; }
          Mod+Ctrl+Page_Up   hotkey-overlay-title="Move Column to Workspace Up"   { move-column-to-workspace-up; }
          Mod+Tab hotkey-overlay-title="Switch to Previous Workspace" { focus-workspace-previous; }

          // Resize
          Mod+R     hotkey-overlay-title="Switch Preset Column Widths" { switch-preset-column-width; }
          Mod+Minus hotkey-overlay-title="Decrease Column Width" { set-column-width "-10%"; }
          Mod+Equal hotkey-overlay-title="Increase Column Width" { set-column-width "+10%"; }

          // Screenshots
          Print           hotkey-overlay-title="Take a Screenshot" { screenshot; }
          Mod+Print       hotkey-overlay-title="Screenshot Window" { screenshot-window; }
          Mod+Shift+Print hotkey-overlay-title="Screenshot Screen" { screenshot-screen; }
      }
    '';

    # Status bar / launcher / notifications / wallpaper / lock are now
    # configured at the home-manager level. Eww config lives in
    # users/mj/home.nix (xdg.configFile."eww/..."); dunst remains at
    # /etc/dunst/dunstrc (set in modules/desktops/leftwm.nix).
  });
}
