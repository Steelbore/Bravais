# Lattice — Product Requirements Document

**Project:** Lattice (A Steelbore NixOS Distribution)
**Version:** 2.0 | **Date:** 2026-04-02
**Author:** Mohamed Hammad | **License:** GPL-3.0-or-later
**Status:** Draft — Pending Approval

---

## 1. Executive Summary

Lattice is a flake-based NixOS configuration implementing the Steelbore Standard. This PRD defines a complete rewrite from the ground up with a modular, opt-in architecture supporting four desktop environments: GNOME (Wayland), COSMIC (Wayland), Niri (Wayland), and LeftWM (X11).

**Core Principles:**

- Memory-safe tooling preferred (Rust-first ecosystem)
- Opt-in modularity via `lib.mkEnableOption`
- Steelbore Color Palette applied universally
- Self-sufficient configuration (no external dependencies beyond nixpkgs)

---

## 2. Architecture Overview

### 2.1 Directory Structure

```text
lattice/
├── flake.nix                      # Flake entry point
├── flake.lock                     # Pinned dependencies
├── lib/                           # Custom Nix helper functions
│   └── default.nix                # mkSteelboreModule, color palette
├── hosts/                         # Machine-specific configurations
│   └── lattice/                   # Primary host
│       ├── default.nix            # Host traits (boot, locale, user)
│       └── hardware.nix           # Hardware configuration
├── modules/                       # NixOS modules (steelbore.* namespace)
│   ├── core/                      # Always-enabled necessities
│   │   ├── default.nix            # Core module entry
│   │   ├── nix.nix                # Nix settings, flakes
│   │   ├── boot.nix               # Bootloader, kernel
│   │   ├── locale.nix             # Timezone, i18n
│   │   ├── audio.nix              # PipeWire audio stack
│   │   └── security.nix           # sudo-rs, polkit
│   ├── theme/                     # Steelbore visual identity
│   │   ├── default.nix            # Color palette, TTY colors
│   │   └── fonts.nix              # Typography
│   ├── hardware/                  # Hardware-specific modules
│   │   ├── fingerprint.nix        # fprintd
│   │   └── intel.nix              # Intel-specific optimizations
│   ├── desktops/                  # Desktop environments (opt-in)
│   │   ├── gnome.nix              # GNOME on Wayland
│   │   ├── cosmic.nix             # COSMIC DE on Wayland
│   │   ├── niri.nix               # Niri + Ironbar on Wayland
│   │   └── leftwm.nix             # LeftWM + Polybar on X11
│   ├── login/                     # Display/login managers
│   │   └── greetd.nix             # greetd + tuigreet
│   └── packages/                  # Application bundles (opt-in)
│       ├── browsers.nix           # Web browsers
│       ├── terminals.nix          # Terminal emulators
│       ├── editors.nix            # Text editors & IDEs
│       ├── development.nix        # Dev tools & languages
│       ├── security.nix           # Encryption & auth
│       ├── networking.nix         # Network tools
│       ├── multimedia.nix         # Media players & processing
│       ├── productivity.nix       # Office & notes
│       ├── system.nix             # System utilities
│       └── ai.nix                 # AI coding assistants
├── users/                         # User profiles
│   └── mj/                        # User "mj"
│       ├── default.nix            # System-level user config
│       └── home.nix               # Home Manager configuration
└── overlays/                      # Package overlays
    └── default.nix                # Custom derivations
```

### 2.2 Module Design Pattern

All modules use the `steelbore.*` namespace with `lib.mkEnableOption`:

```nix
# Example: modules/desktops/niri.nix
{ config, lib, pkgs, ... }:
{
  options.steelbore.desktops.niri = {
    enable = lib.mkEnableOption "Niri scrolling tiling compositor";
  };

  config = lib.mkIf config.steelbore.desktops.niri.enable {
    # Module implementation
  };
}
```

### 2.3 Host Configuration Pattern

Hosts toggle modules declaratively:

```nix
# hosts/lattice/default.nix
{
  steelbore = {
    # Desktops
    desktops.gnome.enable = true;
    desktops.cosmic.enable = true;
    desktops.niri.enable = true;
    desktops.leftwm.enable = true;

    # Hardware
    hardware.fingerprint.enable = true;
    hardware.intel.enable = true;

    # Packages
    packages.browsers.enable = true;
    packages.terminals.enable = true;
    packages.editors.enable = true;
    packages.development.enable = true;
  };
}
```

---

## 3. Steelbore Visual Identity

### 3.1 Color Palette

| Token          | Hex       | RGB                | Role                           |
|----------------|-----------|--------------------|--------------------------------|
| Void Navy      | `#000027` | RGB(000, 000, 039) | Background / Canvas            |
| Molten Amber   | `#D98E32` | RGB(217, 142, 050) | Primary Text / Active Readout  |
| Steel Blue     | `#4B7EB0` | RGB(075, 126, 176) | Primary Accent / Structural    |
| Radium Green   | `#50FA7B` | RGB(080, 250, 123) | Success / Safe Status          |
| Red Oxide      | `#FF5C5C` | RGB(255, 092, 092) | Warning / Error Status         |
| Liquid Coolant | `#8BE9FD` | RGB(139, 233, 253) | Info / Links                   |

**`#000027` (Void Navy) is the mandatory background for ALL Steelbore surfaces.**

### 3.2 Typography

| Context       | Font             | License | Fallback        |
|---------------|------------------|---------|-----------------|
| UI Headers    | Orbitron         | OFL     | Share Tech Mono |
| Code/Terminal | JetBrains Mono   | OFL     | Cascadia Code   |
| HUD/Status    | Share Tech Mono  | OFL     | monospace       |
| Brand/Hero    | Future Earth     | Free    | Orbitron        |

---

## 4. Flake Configuration

### 4.1 Complete `flake.nix`

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{
  description = "Lattice — A Steelbore NixOS Distribution";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # COSMIC Desktop
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional flake inputs
    emacs-ng.url = "github:emacs-ng/emacs-ng";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-cosmic, emacs-ng, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Steelbore color palette as a reusable attribute set
    steelborePalette = {
      voidNavy     = "#000027";
      moltenAmber  = "#D98E32";
      steelBlue    = "#4B7EB0";
      radiumGreen  = "#50FA7B";
      redOxide     = "#FF5C5C";
      liquidCool   = "#8BE9FD";
    };
  in {
    nixosConfigurations.lattice = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit unstable emacs-ng steelborePalette;
      };
      modules = [
        # COSMIC binary cache
        {
          nix.settings = {
            substituters = [ "https://cosmic.cachix.org/" ];
            trusted-public-keys = [
              "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
            ];
          };
        }

        # External modules
        nixos-cosmic.nixosModules.default
        home-manager.nixosModules.home-manager

        # Lattice modules
        ./hosts/lattice
        ./modules/core
        ./modules/theme
        ./modules/hardware
        ./modules/desktops
        ./modules/login
        ./modules/packages

        # Home Manager integration
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit steelborePalette unstable; };
          home-manager.users.mj = import ./users/mj/home.nix;
        }
      ];
    };
  };
}
```

---

## 5. Core Modules

### 5.1 Boot Configuration (`modules/core/boot.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, ... }:

{
  # Bootloader: systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel: XanMod Latest (performance-optimized)
  boot.kernelPackages = unstable.linuxPackages_xanmod_latest;

  # Kernel modules
  boot.initrd.availableKernelModules = [
    "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"
  ];
  boot.kernelModules = [ "kvm-intel" ];
}
```

### 5.2 Nix Settings (`modules/core/nix.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Overlays
  nixpkgs.overlays = [
    (final: prev: {
      # Disable failing tests for sequoia-wot
      sequoia-wot = prev.sequoia-wot.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];
}
```

### 5.3 Locale Configuration (`modules/core/locale.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  # Timezone (UTC for Steelbore Standard compliance)
  time.timeZone = "UTC";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Console/TTY
  console.useXkbConfig = true;
}
```

### 5.4 Audio Configuration (`modules/core/audio.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  # Disable PulseAudio (replaced by PipeWire)
  services.pulseaudio.enable = false;

  # Enable PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true; # Uncomment for JACK support
  };
}
```

### 5.5 Security Configuration (`modules/core/security.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  # Disable standard sudo (C implementation)
  security.sudo.enable = false;

  # Enable sudo-rs (Rust implementation — memory-safe)
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };

  # Polkit for privilege escalation
  security.polkit.enable = true;

  # Tmpfiles rules
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root -"
    "d /var/tmp 1777 root root -"
  ];
}
```

---

## 6. Theme Module

### 6.1 Color Palette (`modules/theme/default.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, steelborePalette, ... }:

{
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
```

### 6.2 Fonts (`modules/theme/fonts.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # UI Headers
    orbitron

    # Code / Terminal
    jetbrains-mono
    cascadia-code

    # Nerd Fonts (icons)
    nerd-fonts.jetbrains-mono
    nerd-fonts.cascadia-code

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
    monospace = [ "JetBrains Mono" "Cascadia Code" "Share Tech Mono" ];
    sansSerif = [ "Orbitron" ];
    serif = [ "Orbitron" ];
  };
}
```

---

## 7. Desktop Environment Modules

### 7.1 GNOME on Wayland (`modules/desktops/gnome.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  options.steelbore.desktops.gnome = {
    enable = lib.mkEnableOption "GNOME Desktop Environment (Wayland)";
  };

  config = lib.mkIf config.steelbore.desktops.gnome.enable {
    # Enable GNOME
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = lib.mkDefault false; # Use greetd instead
    services.xserver.displayManager.gdm.wayland = true;
    services.desktopManager.gnome.enable = true;

    # Force Wayland session
    services.xserver.displayManager.defaultSession = lib.mkDefault "gnome";

    # GNOME packages
    environment.systemPackages = with pkgs; [
      # Core GNOME utilities
      gnome-tweaks
      dconf-editor

      # Extension management
      gnome-extension-manager
      gnome-browser-connector

      # Extensions
      gnomeExtensions.caffeine
      gnomeExtensions.just-perfection
      gnomeExtensions.window-gestures
      gnomeExtensions.wayland-or-x11
      gnomeExtensions.toggler
      gnomeExtensions.vim-alt-tab
      gnomeExtensions.open-bar
      gnomeExtensions.tweaks-in-system-menu
      gnomeExtensions.launcher
      gnomeExtensions.window-title-is-back

      # Portal
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];

    # Exclude bloat
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-music
      epiphany
      geary
      totem
    ];
  };
}
```

### 7.2 COSMIC on Wayland (`modules/desktops/cosmic.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  options.steelbore.desktops.cosmic = {
    enable = lib.mkEnableOption "COSMIC Desktop Environment (Wayland)";
  };

  config = lib.mkIf config.steelbore.desktops.cosmic.enable {
    # Enable COSMIC (from nixos-cosmic flake)
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = false; # Use greetd

    # COSMIC packages
    environment.systemPackages = with pkgs; [
      # Session & Core
      cosmic-session
      cosmic-comp
      cosmic-bg
      cosmic-osd
      cosmic-idle
      cosmic-randr
      cosmic-protocols
      cosmic-settings-daemon

      # Panel & Applets
      cosmic-panel
      cosmic-applets
      cosmic-launcher
      cosmic-applibrary
      cosmic-notifications
      cosmic-workspaces-epoch

      # Applications
      cosmic-term
      cosmic-edit
      cosmic-files
      cosmic-store
      cosmic-reader
      cosmic-player
      cosmic-screenshot
      cosmic-settings
      cosmic-initial-setup

      # Icons & Theming
      cosmic-icons
      cosmic-wallpapers

      # Extensions
      cosmic-ext-ctl
      cosmic-ext-tweaks
      cosmic-ext-calculator
      cosmic-ext-applet-minimon
      cosmic-ext-applet-caffeine
      cosmic-ext-applet-privacy-indicator
      cosmic-ext-applet-external-monitor-brightness

      # Design Tools
      cosmic-design-demo

      # Portal
      xdg-desktop-portal-cosmic

      # Task management
      tasks
    ];
  };
}
```

### 7.3 Niri on Wayland (`modules/desktops/niri.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, steelborePalette, ... }:

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
      unstable.anyrun           # Application launcher (Rust)
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
          Mod+Return { spawn "alacritty"; }
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
```

### 7.4 LeftWM on X11 (`modules/desktops/leftwm.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, steelborePalette, ... }:

{
  options.steelbore.desktops.leftwm = {
    enable = lib.mkEnableOption "LeftWM tiling window manager (X11)";
  };

  config = lib.mkIf config.steelbore.desktops.leftwm.enable {
    # Enable X11 and LeftWM
    services.xserver.enable = true;
    services.xserver.windowManager.leftwm.enable = true;

    # X11 keyboard layout
    services.xserver.xkb = {
      layout = "us,ar";
      options = "grp:ctrl_space_toggle";
    };

    # LeftWM and companion packages
    environment.systemPackages = with pkgs; [
      leftwm
      leftwm-theme
      leftwm-config

      # Launcher
      unstable.rlaunch           # Application launcher (Rust)
      rofi                       # Alternative launcher
      dmenu                      # Minimal launcher

      # Bar
      polybar                    # Status bar

      # Compositor
      picom                      # Compositor for transparency/effects

      # Utilities
      feh                        # Background setter
      dunst                      # Notification daemon
      xclip                      # Clipboard
      xsel                       # Clipboard
      maim                       # Screenshot
      xdotool                    # X11 automation
      numlockx                   # NumLock control
    ];

    # LeftWM configuration
    environment.etc."leftwm/config.ron".text = ''
      // Steelbore LeftWM Configuration
      // The Steelbore Standard — X11 Tiling

      #![enable(implicit_some)]
      (
          modkey: "Mod4",
          mousekey: "Mod4",
          workspaces: [],
          tags: ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
          max_window_width: None,
          layouts: [
              MainAndVertStack,
              MainAndHorizontalStack,
              MainAndDeck,
              GridHorizontal,
              EvenHorizontal,
              EvenVertical,
              Fibonacci,
              Monocle,
          ],
          layout_mode: Tag,
          insert_behavior: Bottom,
          scratchpad: [
              (name: "Terminal", value: "alacritty", x: 50, y: 50, width: 1200, height: 800),
          ],
          window_rules: [],
          disable_current_tag_swap: false,
          disable_tile_drag: false,
          disable_window_snap: false,
          focus_behaviour: Sloppy,
          focus_new_windows: true,
          single_window_border: true,
          sloppy_mouse_follows_focus: true,
          auto_derive_workspaces: true,
          keybind: [
              // Session
              (command: Execute, value: "loginctl kill-session $XDG_SESSION_ID", modifier: ["modkey", "Shift"], key: "e"),

              // Applications
              (command: Execute, value: "alacritty", modifier: ["modkey"], key: "Return"),
              (command: Execute, value: "rlaunch", modifier: ["modkey"], key: "d"),
              (command: Execute, value: "rofi -show drun", modifier: ["modkey", "Shift"], key: "d"),

              // Window management
              (command: CloseWindow, value: "", modifier: ["modkey"], key: "q"),
              (command: ToggleFullScreen, value: "", modifier: ["modkey"], key: "f"),
              (command: ToggleFloating, value: "", modifier: ["modkey", "Shift"], key: "f"),

              // Focus (Vim-style)
              (command: FocusWindowLeft, value: "", modifier: ["modkey"], key: "h"),
              (command: FocusWindowRight, value: "", modifier: ["modkey"], key: "l"),
              (command: FocusWindowUp, value: "", modifier: ["modkey"], key: "k"),
              (command: FocusWindowDown, value: "", modifier: ["modkey"], key: "j"),

              // Focus (Arrow keys)
              (command: FocusWindowLeft, value: "", modifier: ["modkey"], key: "Left"),
              (command: FocusWindowRight, value: "", modifier: ["modkey"], key: "Right"),
              (command: FocusWindowUp, value: "", modifier: ["modkey"], key: "Up"),
              (command: FocusWindowDown, value: "", modifier: ["modkey"], key: "Down"),

              // Move windows (Vim-style)
              (command: MoveWindowLeft, value: "", modifier: ["modkey", "Shift"], key: "h"),
              (command: MoveWindowRight, value: "", modifier: ["modkey", "Shift"], key: "l"),
              (command: MoveWindowUp, value: "", modifier: ["modkey", "Shift"], key: "k"),
              (command: MoveWindowDown, value: "", modifier: ["modkey", "Shift"], key: "j"),

              // Layouts
              (command: NextLayout, value: "", modifier: ["modkey"], key: "space"),
              (command: PreviousLayout, value: "", modifier: ["modkey", "Shift"], key: "space"),

              // Workspaces
              (command: GotoTag, value: "1", modifier: ["modkey"], key: "1"),
              (command: GotoTag, value: "2", modifier: ["modkey"], key: "2"),
              (command: GotoTag, value: "3", modifier: ["modkey"], key: "3"),
              (command: GotoTag, value: "4", modifier: ["modkey"], key: "4"),
              (command: GotoTag, value: "5", modifier: ["modkey"], key: "5"),
              (command: GotoTag, value: "6", modifier: ["modkey"], key: "6"),
              (command: GotoTag, value: "7", modifier: ["modkey"], key: "7"),
              (command: GotoTag, value: "8", modifier: ["modkey"], key: "8"),
              (command: GotoTag, value: "9", modifier: ["modkey"], key: "9"),
              (command: MoveToTag, value: "1", modifier: ["modkey", "Shift"], key: "1"),
              (command: MoveToTag, value: "2", modifier: ["modkey", "Shift"], key: "2"),
              (command: MoveToTag, value: "3", modifier: ["modkey", "Shift"], key: "3"),
              (command: MoveToTag, value: "4", modifier: ["modkey", "Shift"], key: "4"),
              (command: MoveToTag, value: "5", modifier: ["modkey", "Shift"], key: "5"),
              (command: MoveToTag, value: "6", modifier: ["modkey", "Shift"], key: "6"),
              (command: MoveToTag, value: "7", modifier: ["modkey", "Shift"], key: "7"),
              (command: MoveToTag, value: "8", modifier: ["modkey", "Shift"], key: "8"),
              (command: MoveToTag, value: "9", modifier: ["modkey", "Shift"], key: "9"),

              // Resize
              (command: IncreaseMainWidth, value: "5", modifier: ["modkey"], key: "equal"),
              (command: DecreaseMainWidth, value: "5", modifier: ["modkey"], key: "minus"),

              // Scratchpad
              (command: ToggleScratchPad, value: "Terminal", modifier: ["modkey"], key: "grave"),
          ],
          state_path: None,
      )
    '';

    # LeftWM theme (Steelbore)
    environment.etc."leftwm/themes/current/theme.ron".text = ''
      // Steelbore LeftWM Theme
      (
          border_width: 2,
          margin: 8,
          workspace_margin: Some(8),
          default_border_color: "${steelborePalette.steelBlue}",
          floating_border_color: "${steelborePalette.liquidCool}",
          focused_border_color: "${steelborePalette.moltenAmber}",
          on_new_window_cmd: None,
      )
    '';

    # LeftWM autostart (up script)
    environment.etc."leftwm/themes/current/up".text = ''
      #!/usr/bin/env bash
      # Steelbore LeftWM Startup Script

      # Set background
      feh --bg-solid "${steelborePalette.voidNavy}" &

      # Start compositor
      picom --config /etc/leftwm/themes/current/picom.conf &

      # Start notification daemon
      dunst &

      # Start polybar
      polybar steelbore &

      # Enable NumLock
      numlockx on &
    '';

    # LeftWM shutdown (down script)
    environment.etc."leftwm/themes/current/down".text = ''
      #!/usr/bin/env bash
      # Steelbore LeftWM Shutdown Script
      pkill polybar
      pkill picom
      pkill dunst
    '';

    # Polybar configuration (Steelbore theme)
    environment.etc."leftwm/themes/current/polybar.ini".text = ''
      ; Steelbore Polybar Configuration

      [colors]
      background = ${steelborePalette.voidNavy}
      foreground = ${steelborePalette.moltenAmber}
      accent = ${steelborePalette.steelBlue}
      success = ${steelborePalette.radiumGreen}
      warning = ${steelborePalette.redOxide}
      info = ${steelborePalette.liquidCool}

      [bar/steelbore]
      width = 100%
      height = 32
      fixed-center = true

      background = ''${colors.background}
      foreground = ''${colors.foreground}

      line-size = 2
      line-color = ''${colors.accent}

      border-bottom-size = 2
      border-bottom-color = ''${colors.accent}

      padding-left = 2
      padding-right = 2
      module-margin = 1

      font-0 = "Share Tech Mono:size=12;2"
      font-1 = "JetBrainsMono Nerd Font:size=12;2"

      modules-left = leftwm-tags
      modules-center = date
      modules-right = cpu memory network

      cursor-click = pointer
      cursor-scroll = ns-resize

      [module/leftwm-tags]
      type = custom/script
      exec = leftwm-state -w "$LEFTWM_STATE_SOCKET" -t "$LEFTWM_THEME_DIR/template.liquid"
      tail = true

      [module/date]
      type = internal/date
      interval = 1
      date = "%Y-%m-%d"
      time = "%H:%M:%S"
      label = "%time% :: %date%"
      label-foreground = ''${colors.foreground}

      [module/cpu]
      type = internal/cpu
      interval = 1
      label = "CPU: %percentage%%"
      label-foreground = ''${colors.success}

      [module/memory]
      type = internal/memory
      interval = 1
      label = "RAM: %percentage_used%%"
      label-foreground = ''${colors.success}

      [module/network]
      type = internal/network
      interface-type = wireless
      interval = 1
      label-connected = "%essid%"
      label-connected-foreground = ''${colors.info}
      label-disconnected = "Offline"
      label-disconnected-foreground = ''${colors.warning}
    '';

    # Polybar template for LeftWM tags
    environment.etc."leftwm/themes/current/template.liquid".text = ''
      {% for tag in workspace.tags %}
      %{A1:leftwm-command "SendWorkspaceToTag {{ workspace.index }} {{ tag.index }}":}
      {% if tag.mine %}
      %{F${steelborePalette.moltenAmber}}%{+u}
      {% elsif tag.visible %}
      %{F${steelborePalette.liquidCool}}
      {% elsif tag.busy %}
      %{F${steelborePalette.steelBlue}}
      {% else %}
      %{F${steelborePalette.steelBlue}50}
      {% endif %}
        {{ tag.name }}
      %{-u}%{F-}%{A}
      {% endfor %}
    '';

    # Picom configuration
    environment.etc."leftwm/themes/current/picom.conf".text = ''
      # Steelbore Picom Configuration
      backend = "glx";
      vsync = true;

      # Opacity
      active-opacity = 1.0;
      inactive-opacity = 0.95;
      frame-opacity = 1.0;

      # Fading
      fading = true;
      fade-delta = 5;
      fade-in-step = 0.03;
      fade-out-step = 0.03;

      # Rounded corners
      corner-radius = 0;

      # Shadows
      shadow = false;
    '';

    # Dunst notification configuration
    environment.etc."dunst/dunstrc".text = ''
      # Steelbore Dunst Configuration
      [global]
      monitor = 0
      follow = mouse
      width = 350
      height = 150
      origin = top-right
      offset = 10x40

      transparency = 5
      padding = 16
      horizontal_padding = 16
      frame_width = 2
      frame_color = "${steelborePalette.steelBlue}"
      separator_color = frame

      font = "Share Tech Mono 12"
      line_height = 0
      markup = full
      format = "<b>%s</b>\n%b"
      alignment = left

      icon_position = left
      max_icon_size = 48

      [urgency_low]
      background = "${steelborePalette.voidNavy}"
      foreground = "${steelborePalette.liquidCool}"
      timeout = 5

      [urgency_normal]
      background = "${steelborePalette.voidNavy}"
      foreground = "${steelborePalette.moltenAmber}"
      timeout = 10

      [urgency_critical]
      background = "${steelborePalette.voidNavy}"
      foreground = "${steelborePalette.redOxide}"
      frame_color = "${steelborePalette.redOxide}"
      timeout = 0
    '';
  };
}
```

---

## 8. Login Manager Module

### 8.1 greetd with tuigreet (`modules/login/greetd.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

let
  # Session selector script
  sessionScript = pkgs.writeShellScriptBin "steelbore-session" ''
    echo "╔════════════════════════════════════════╗"
    echo "║     STEELBORE :: SESSION SELECTOR      ║"
    echo "╠════════════════════════════════════════╣"
    echo "║  1) Niri      (Wayland) — Recommended  ║"
    echo "║  2) COSMIC    (Wayland)                ║"
    echo "║  3) GNOME     (Wayland)                ║"
    echo "║  4) LeftWM    (X11)                    ║"
    echo "╚════════════════════════════════════════╝"
    read -p "Select [1-4]: " choice

    case $choice in
      1) exec niri-session ;;
      2) exec start-cosmic ;;
      3) exec gnome-session ;;
      4) exec startx /usr/bin/env leftwm ;;
      *) echo "Invalid selection"; exit 1 ;;
    esac
  '';
in
{
  # greetd configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Default to Niri (Steelbore Standard)
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri-session";
        user = "mj";
      };
    };
  };

  # Packages
  environment.systemPackages = [
    pkgs.greetd
    pkgs.tuigreet
    pkgs.lemurs
    sessionScript
  ];

  # Available sessions
  services.displayManager.sessionPackages = with pkgs; [
    niri
  ];
}
```

---

## 9. Package Modules

### 9.1 Browsers (`modules/packages/browsers.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, ... }:

{
  options.steelbore.packages.browsers = {
    enable = lib.mkEnableOption "Web browsers";
  };

  config = lib.mkIf config.steelbore.packages.browsers.enable {
    # Firefox (system-managed)
    programs.firefox.enable = true;

    environment.systemPackages = [
      unstable.google-chrome
      unstable.brave
      unstable.microsoft-edge
      unstable.librewolf
    ];
  };
}
```

### 9.2 Terminals (`modules/packages/terminals.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, steelborePalette, ... }:

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
      unstable.ptyxis            # GNOME terminal
      unstable.waveterm          # AI-native terminal
      unstable.warp-terminal     # AI-powered terminal
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
```

### 9.3 Editors (`modules/packages/editors.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, emacs-ng, ... }:

{
  options.steelbore.packages.editors = {
    enable = lib.mkEnableOption "Text editors and IDEs";
  };

  config = lib.mkIf config.steelbore.packages.editors.enable {
    environment.systemPackages = with pkgs; [
      # TUI Editors (Rust preferred)
      helix                      # Rust — Modal editor
      amp                        # Rust — Vim-like
      msedit                     # Rust — MS-DOS style

      # TUI Editors (Standard)
      neovim
      vim
      mg                         # Micro Emacs
      mc                         # Midnight Commander

      # GUI Editors (Rust preferred)
      zed-editor                 # Rust — Fast collaborative
      lapce                      # Rust — Lightning fast
      neovide                    # Rust — Neovim GUI
      cosmic-edit                # Rust — COSMIC editor

      # GUI Editors (Standard)
      emacs-ng.packages.${pkgs.stdenv.hostPlatform.system}.default
      emacs-pgtk
      unstable.vscode
      vscodium
      unstable.code-cursor
      gedit
    ];
  };
}
```

### 9.4 Development Tools (`modules/packages/development.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, ... }:

{
  options.steelbore.packages.development = {
    enable = lib.mkEnableOption "Development tools and languages";
  };

  config = lib.mkIf config.steelbore.packages.development.enable {
    environment.systemPackages = with pkgs; [
      # Git & Version Control (Rust preferred)
      git
      gitui                      # Rust — TUI for Git
      delta                      # Rust — Syntax-highlighting pager
      jujutsu                    # Rust — Git-compatible VCS (jj)
      unstable.gh                # Go — GitHub CLI
      github-desktop

      # Rust Toolchain
      rustup
      cargo
      cargo-update

      # Build & Task Tools (Rust preferred)
      just                       # Rust — Command runner
      sad                        # Rust — Batch search & replace
      pueue                      # Rust — Task management daemon
      tokei                      # Rust — Code statistics

      # Environment Management
      lorri                      # Rust — Nix env daemon
      dotter                     # Rust — Dotfile manager

      # Languages
      jdk
      php

      # Nix Ecosystem
      nixfmt                     # Rust — Nix formatter
      cachix
      nix
      guix
      emacsPackages.guix
    ];

    # Git configuration
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        core.editor = "hx";
        color.ui = true;
      };
    };
  };
}
```

### 9.5 Security Tools (`modules/packages/security.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, ... }:

{
  options.steelbore.packages.security = {
    enable = lib.mkEnableOption "Security and encryption tools";
  };

  config = lib.mkIf config.steelbore.packages.security.enable {
    environment.systemPackages = with pkgs; [
      # Encryption (Rust preferred)
      age                        # Rust — Modern encryption
      rage                       # Rust — age implementation
      sops                       # Go — Secret management

      # PGP / Sequoia Stack (Rust)
      sequoia-sq                 # Rust — Sequoia CLI
      sequoia-chameleon-gnupg    # Rust — GnuPG drop-in
      sequoia-wot                # Rust — Web of Trust
      sequoia-sqv                # Rust — Signature verifier
      sequoia-sqop               # Rust — Stateless OpenPGP

      # Password Managers
      rbw                        # Rust — Bitwarden CLI
      unstable.bitwarden-cli
      unstable.bitwarden-desktop
      authenticator              # Rust — 2FA/OTP

      # SSH
      openssh
      openssh_hpn

      # Backup
      unstable.pika-backup       # Rust — Borg frontend

      # Secure Boot
      sbctl                      # Rust — Secure Boot manager
    ];
  };
}
```

### 9.6 Networking Tools (`modules/packages/networking.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, ... }:

{
  options.steelbore.packages.networking = {
    enable = lib.mkEnableOption "Networking and internet tools";
  };

  config = lib.mkIf config.steelbore.packages.networking.enable {
    environment.systemPackages = with pkgs; [
      # Network Management
      impala                     # Rust — TUI for iwd
      iwd

      # HTTP Clients (Rust preferred)
      xh                         # Rust — curl replacement
      monolith                   # Rust — webpage archiver
      curlFull
      wget2

      # Diagnostics (Rust preferred)
      gping                      # Rust — Graphical ping
      trippy                     # Rust — Network diagnostic
      lychee                     # Rust — Link checker
      rustscan                   # Rust — Port scanner
      sniffglue                  # Rust — Packet sniffer
      bandwhich                  # Rust — Bandwidth monitor

      # GUI Applications
      unstable.sniffnet          # Rust — Network monitor
      mullvad-vpn                # Rust — VPN client
      unstable.rqbit             # Rust — BitTorrent

      # Download Managers
      aria2
      uget

      # Clipboard
      wl-clipboard
      wl-clipboard-rs            # Rust

      # DNS & Services
      dnsmasq
      atftp
      adguardhome
    ];
  };
}
```

### 9.7 Multimedia (`modules/packages/multimedia.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  options.steelbore.packages.multimedia = {
    enable = lib.mkEnableOption "Multimedia players and processing tools";
  };

  config = lib.mkIf config.steelbore.packages.multimedia.enable {
    environment.systemPackages = with pkgs; [
      # Video Players
      mpv
      vlc
      cosmic-player              # Rust — COSMIC player

      # Audio Players (Rust preferred)
      amberol                    # Rust — Local music
      termusic                   # Rust — TUI music
      ncspot                     # Rust — Spotify TUI
      psst                       # Rust — Spotify GUI
      shortwave                  # Rust — Internet radio

      # Image Viewers (Rust preferred)
      loupe                      # Rust — Image viewer
      viu                        # Rust — CLI image viewer
      emulsion                   # Rust — Image viewer

      # Audio Recognition
      mousai                     # Rust — Song identification

      # Processing (Rust preferred)
      rav1e                      # Rust — AV1 encoder
      gifski                     # Rust — GIF encoder
      oxipng                     # Rust — PNG optimizer
      gyroflow                   # Rust — Video stabilization
      video-trimmer              # Rust — Video trimmer
      ffmpeg

      # Downloaders
      yt-dlp
    ];
  };
}
```

### 9.8 Productivity (`modules/packages/productivity.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, ... }:

{
  options.steelbore.packages.productivity = {
    enable = lib.mkEnableOption "Office and productivity applications";
  };

  config = lib.mkIf config.steelbore.packages.productivity.enable {
    environment.systemPackages = with pkgs; [
      # Knowledge Management (Rust preferred)
      appflowy                   # Rust — Open source Notion
      affine                     # Rust — Knowledge base

      # Office Suites
      libreoffice-fresh
      onlyoffice-desktopeditors

      # Utilities
      qalculate-gtk

      # Communication (Rust preferred)
      iamb                       # Rust — Matrix TUI
      fractal                    # Rust — Matrix GUI
      newsflash                  # Rust — RSS reader
      unstable.tutanota-desktop
      onedriver                  # Go — OneDrive
    ];
  };
}
```

### 9.9 System Utilities (`modules/packages/system.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, ... }:

{
  options.steelbore.packages.system = {
    enable = lib.mkEnableOption "System utilities and modern Unix tools";
  };

  config = lib.mkIf config.steelbore.packages.system.enable {
    environment.systemPackages = with pkgs; [
      # Modern Unix (Rust preferred)
      fd                         # Rust — find replacement
      ripgrep                    # Rust — grep replacement
      bat                        # Rust — cat replacement
      eza                        # Rust — ls replacement
      sd                         # Rust — sed replacement
      zoxide                     # Rust — cd replacement
      procs                      # Rust — ps replacement
      dust                       # Rust — du replacement
      dua                        # Rust — Interactive du

      # Coreutils reimplementation (Rust)
      uutils-coreutils
      uutils-diffutils
      uutils-findutils

      # File Management (Rust preferred)
      yazi                       # Rust — TUI file manager
      broot                      # Rust — Tree navigator
      unstable.superfile         # Go — TUI file manager
      unstable.spacedrive        # Rust — Cross-platform explorer
      fclones                    # Rust — Duplicate finder
      kondo                      # Rust — Project cleaner
      pipe-rename                # Rust — Interactive rename
      ouch                       # Rust — Archive tool

      # Disk Management (Rust preferred)
      unstable.disktui           # Rust — Partition manager
      gptman                     # Rust — GPT manager

      # System Monitoring (Rust preferred)
      bottom                     # Rust — htop replacement
      kmon                       # Rust — Kernel manager
      macchina                   # Rust — System fetch
      bandwhich                  # Rust — Bandwidth monitor
      mission-center             # Rust — Task manager
      htop
      btop
      gotop
      fastfetch
      i7z
      hw-probe

      # Text Processing (Rust preferred)
      jaq                        # Rust — jq replacement
      teip                       # Rust — Masking tool
      htmlq                      # Rust — HTML selector
      skim                       # Rust — Fuzzy finder
      tealdeer                   # Rust — tldr client
      mdcat                      # Rust — Markdown renderer
      difftastic                 # Rust — Structural diff

      # Shells (Rust preferred)
      nushell                    # Rust — Modern shell
      brush                      # Rust — Bash compatible
      ion                        # Rust — Shell
      starship                   # Rust — Prompt
      atuin                      # Rust — Shell history
      pipr                       # Rust — Pipeline builder
      unstable.moor              # Rust — Shell
      unstable.powershell

      # Multiplexers
      zellij                     # Rust — Terminal multiplexer
      screen

      # Recording
      t-rec                      # Rust — Terminal recorder

      # Containers & Virtualization
      distrobox
      boxbuddy                   # Rust — Distrobox GUI
      qemu
      flatpak
      bubblewrap

      # System Management
      topgrade                   # Rust — Universal updater
      paru                       # Rust — AUR helper
      doas
      os-prober
      kbd
      numlockx
      xremap                     # Rust — Key remapper
      input-leap

      # Archiving
      p7zip
      zip
      unzip

      # ZFS
      zfs
      unstable.antigravity       # Rust

      # Benchmarking
      phoronix-test-suite
      perf
    ];

    # Flatpak service
    services.flatpak.enable = true;
  };
}
```

### 9.10 AI Tools (`modules/packages/ai.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, unstable, ... }:

{
  options.steelbore.packages.ai = {
    enable = lib.mkEnableOption "AI coding assistants and tools";
  };

  config = lib.mkIf config.steelbore.packages.ai.enable {
    environment.systemPackages = with pkgs; [
      # AI Coding Assistants (Rust preferred)
      aichat                     # Rust — Universal chat REPL
      gemini-cli                 # Rust — Gemini CLI

      # AI Coding Assistants (Other)
      opencode                   # Go — Coding agent
      unstable.codex
      unstable.github-copilot-cli
      unstable.gpt-cli
      unstable.mcp-nixos
      claude-code
    ];
  };
}
```

---

## 10. Hardware Modules

### 10.1 Fingerprint Reader (`modules/hardware/fingerprint.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  options.steelbore.hardware.fingerprint = {
    enable = lib.mkEnableOption "Fingerprint reader support";
  };

  config = lib.mkIf config.steelbore.hardware.fingerprint.enable {
    services.fprintd.enable = true;

    environment.systemPackages = [ pkgs.fprintd ];
  };
}
```

### 10.2 Intel Optimizations (`modules/hardware/intel.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, lib, pkgs, ... }:

{
  options.steelbore.hardware.intel = {
    enable = lib.mkEnableOption "Intel CPU optimizations";
  };

  config = lib.mkIf config.steelbore.hardware.intel.enable {
    boot.kernelModules = [ "kvm-intel" ];

    hardware.cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Build optimization flags for x86-64-v4 (AVX-512)
    environment.sessionVariables = {
      RUSTFLAGS = "-C target-cpu=x86-64-v4 -C opt-level=3";
      GOAMD64 = "v4";
      CFLAGS = "-march=x86-64-v4 -O3 -pipe -fno-plt -flto=auto";
      CXXFLAGS = "-march=x86-64-v4 -O3 -pipe -fno-plt -flto=auto";
    };
  };
}
```

---

## 11. Host Configuration

### 11.1 Lattice Host (`hosts/lattice/default.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, pkgs, lib, unstable, ... }:

{
  imports = [
    ./hardware.nix
  ];

  # Hostname
  networking.hostName = "lattice";
  networking.networkmanager.enable = true;

  # X11 (for LeftWM)
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us,ar";
    options = "grp:ctrl_space_toggle";
  };

  # Printing
  services.printing.enable = true;

  # User account
  users.users.mj = {
    isNormalUser = true;
    description = "Mohamed Hammad";
    extraGroups = [ "networkmanager" "wheel" "input" "video" "audio" "docker" ];
    shell = pkgs.nushell;
  };

  # Steelbore module toggles
  steelbore = {
    # Desktop environments
    desktops.gnome.enable = true;
    desktops.cosmic.enable = true;
    desktops.niri.enable = true;
    desktops.leftwm.enable = true;

    # Hardware
    hardware.fingerprint.enable = true;
    hardware.intel.enable = true;

    # Package bundles
    packages.browsers.enable = true;
    packages.terminals.enable = true;
    packages.editors.enable = true;
    packages.development.enable = true;
    packages.security.enable = true;
    packages.networking.enable = true;
    packages.multimedia.enable = true;
    packages.productivity.enable = true;
    packages.system.enable = true;
    packages.ai.enable = true;
  };

  system.stateVersion = "25.11";
}
```

### 11.2 Hardware Configuration (`hosts/lattice/hardware.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
# Generated by nixos-generate-config — Do not edit manually
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/667c95b9-16ac-449a-b36c-7a4e156620c3";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/30F4-BB7D";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

---

## 12. User Configuration

### 12.1 User System Config (`users/mj/default.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, pkgs, ... }:

{
  users.users.mj = {
    isNormalUser = true;
    description = "Mohamed Hammad";
    extraGroups = [ "networkmanager" "wheel" "input" "video" "audio" "docker" ];
    shell = pkgs.nushell;
  };
}
```

### 12.2 Home Manager Config (`users/mj/home.nix`)

```nix
# SPDX-License-Identifier: GPL-3.0-or-later
{ config, pkgs, lib, steelborePalette, unstable, ... }:

{
  home.username = "mj";
  home.homeDirectory = "/home/mj";
  home.stateVersion = "25.11";

  # Steelbore project symlink
  home.file."steelbore".source = config.lib.file.mkOutOfStoreSymlink "/steelbore";

  # Keyboard layout
  home.keyboard = {
    layout = "us,ar";
    options = [ "grp:ctrl_space_toggle" ];
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
    STEELBORE_THEME = "true";
  };

  # Programs
  programs = {
    # Git configuration
    git = {
      enable = true;
      signing = {
        key = "B36135D768BF4D704B6061A8C69EC44335B60CCB";
        signByDefault = true;
      };
      extraConfig = {
        user = {
          name = "UnbreakableMJ";
          email = "34196588+UnbreakableMJ@users.noreply.github.com";
        };
        init.defaultBranch = "main";
        gpg = {
          format = "openpgp";
          program = "${pkgs.sequoia-chameleon-gnupg}/bin/gpg";
        };
      };
    };

    # Starship prompt (Steelbore theme)
    starship = {
      enable = true;
      settings = {
        format = "$directory$git_branch$git_status$cmd_duration$character";
        palette = "steelbore";

        palettes.steelbore = {
          void_navy = steelborePalette.voidNavy;
          molten_amber = steelborePalette.moltenAmber;
          steel_blue = steelborePalette.steelBlue;
          radium_green = steelborePalette.radiumGreen;
          red_oxide = steelborePalette.redOxide;
          liquid_coolant = steelborePalette.liquidCool;
        };

        directory = {
          style = "bold steel_blue";
          truncate_to_repo = true;
        };

        character = {
          success_symbol = "[➜](bold radium_green)";
          error_symbol = "[✗](bold red_oxide)";
        };

        git_branch = {
          style = "bold liquid_coolant";
          symbol = " ";
        };

        git_status = {
          style = "bold red_oxide";
          format = "([\\[$all_status$ahead_behind\\]]($style) )";
        };

        cmd_duration = {
          style = "bold molten_amber";
          min_time = 2000;
        };
      };
    };

    # Nushell configuration
    nushell = {
      enable = true;
      configFile.text = ''
        $env.config = {
          show_banner: false,
          ls: { use_ls_colors: true, clickable_links: true },
          cursor_shape: { emacs: block, vi_insert: block, vi_normal: block },
        }

        # Steelbore Telemetry Aliases
        alias ll = ls -l
        alias lla = ls -la
        alias telemetry = macchina
        alias sensors = watch -n 1 sensors
        alias sys-logs = journalctl -p 3 -xb
        alias network-diag = gping google.com
        alias top-processes = bottom
        alias disk-telemetry = yazi
        alias edit = hx

        # Project Steelbore Identity
        def steelbore [] {
          print "╔══════════════════════════════════════════════════════╗"
          print "║  STEELBORE :: Industrial Sci-Fi Utility Environment  ║"
          print "╠══════════════════════════════════════════════════════╣"
          print "║  STATUS    :: ACTIVE                                 ║"
          print "║  LOAD      :: NOMINAL                                ║"
          print "║  INTEGRITY :: VERIFIED                               ║"
          print "╚══════════════════════════════════════════════════════╝"
        }
      '';
    };

    # Alacritty (Steelbore theme)
    alacritty = {
      enable = true;
      settings = {
        window = {
          padding = { x = 10; y = 10; };
          dynamic_title = true;
          opacity = 0.95;
        };
        font = {
          normal = { family = "JetBrains Mono"; style = "Regular"; };
          size = 12.0;
        };
        colors = {
          primary = {
            background = steelborePalette.voidNavy;
            foreground = steelborePalette.moltenAmber;
          };
          cursor = {
            text = steelborePalette.voidNavy;
            cursor = steelborePalette.moltenAmber;
          };
          selection = {
            text = steelborePalette.voidNavy;
            background = steelborePalette.steelBlue;
          };
          normal = {
            black = steelborePalette.voidNavy;
            red = steelborePalette.redOxide;
            green = steelborePalette.radiumGreen;
            yellow = steelborePalette.moltenAmber;
            blue = steelborePalette.steelBlue;
            magenta = steelborePalette.steelBlue;
            cyan = steelborePalette.liquidCool;
            white = steelborePalette.moltenAmber;
          };
          bright = {
            black = steelborePalette.steelBlue;
            red = steelborePalette.redOxide;
            green = steelborePalette.radiumGreen;
            yellow = steelborePalette.moltenAmber;
            blue = steelborePalette.liquidCool;
            magenta = steelborePalette.liquidCool;
            cyan = steelborePalette.liquidCool;
            white = steelborePalette.moltenAmber;
          };
        };
      };
    };
  };

  # XDG config files
  xdg.configFile = {
    # Niri user config (inherits from system, adds user preferences)
    "niri/config.kdl".text = ''
      // User-specific Niri overrides
      // System config at /etc/niri/config.kdl provides base configuration

      layout {
          focus-ring {
              enable
              width 2
              active-color "${steelborePalette.moltenAmber}"
              inactive-color "${steelborePalette.steelBlue}"
          }
          border { off }
          gaps 8
      }

      spawn-at-startup "swaybg" "-c" "${steelborePalette.voidNavy}"
      spawn-at-startup "ironbar"
      spawn-at-startup "wired"

      binds {
          Mod+Shift+E { quit; }
          Mod+Return { spawn "alacritty"; }
          Mod+D { spawn "onagre"; }
          Mod+Q { close-window; }
          Mod+F { maximize-column; }

          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+K { focus-window-up; }
          Mod+J { focus-window-down; }

          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
          Mod+Shift+K { move-window-up; }
          Mod+Shift+J { move-window-down; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
      }
    '';

    # Ironbar user config
    "ironbar/config.yaml".text = ''
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

    "ironbar/style.css".text = ''
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
      }

      .workspaces button.active {
          color: ${steelborePalette.moltenAmber};
          border-bottom: 2px solid ${steelborePalette.moltenAmber};
      }

      .clock {
          color: ${steelborePalette.moltenAmber};
          font-weight: bold;
      }

      .sys_info {
          color: ${steelborePalette.radiumGreen};
      }
    '';

    # WezTerm user config
    "wezterm/wezterm.lua".text = ''
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

    # Rio user config
    "rio/config.toml".text = ''
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
```

---

## 13. Verification Plan

### 13.1 Build Verification

```bash
# Check flake validity
nix flake check

# Show flake outputs
nix flake show

# Dry-run build
nixos-rebuild dry-build --flake .#lattice

# Build without switching
nixos-rebuild build --flake .#lattice

# Switch to new configuration
sudo nixos-rebuild switch --flake .#lattice
```

### 13.2 Desktop Environment Verification

| Desktop | Verification Command | Expected Result |
| ------- | -------------------- | --------------- |
| GNOME | `gnome-session --version` | Session starts on Wayland |
| COSMIC | `cosmic-session --version` | Session starts with panel |
| Niri | `niri --version` | WM starts with Ironbar |
| LeftWM | `leftwm --version` | WM starts with Polybar |

### 13.3 Steelbore Standard Compliance

- [ ] **§2** Metallurgical naming: `Lattice` (crystal structure)
- [ ] **§3.1** Memory safety: Rust-first packages, sudo-rs
- [ ] **§3.2** Performance: XanMod kernel, x86-64-v4 flags
- [ ] **§3.3** Security: Sequoia PGP, polkit, secure boot ready
- [ ] **§4** License: GPL-3.0-or-later, SPDX headers
- [ ] **§6** PFA: No telemetry, local storage default
- [ ] **§7** Key bindings: CUA + Vim (hjkl) in all WMs
- [ ] **§8** Color palette: Void Navy background everywhere
- [ ] **§9** Typography: Share Tech Mono, JetBrains Mono
- [ ] **§11** Date/Time: ISO 8601, 24h, UTC

---

## 14. Migration Checklist

1. [ ] Create new directory structure
2. [ ] Write `lib/default.nix` with helpers
3. [ ] Implement core modules (`boot`, `nix`, `locale`, `audio`, `security`)
4. [ ] Implement theme modules (`colors`, `fonts`)
5. [ ] Implement hardware modules (`fingerprint`, `intel`)
6. [ ] Implement desktop modules (`gnome`, `cosmic`, `niri`, `leftwm`)
7. [ ] Implement login module (`greetd`)
8. [ ] Implement package modules (10 categories)
9. [ ] Implement user configuration (`mj`)
10. [ ] Write `flake.nix` with all inputs
11. [ ] Copy `hardware.nix` from current system
12. [ ] Run `nix flake check`
13. [ ] Run `nixos-rebuild dry-build --flake .#lattice`
14. [ ] Run `nixos-rebuild switch --flake .#lattice`
15. [ ] Verify all four desktop environments boot
16. [ ] Verify Steelbore theme applies to all surfaces

---

## 15. Package Summary

### 15.1 Total Package Count by Category

| Category | Rust | Other | Total |
| -------- | ---- | ----- | ----- |
| Browsers | 0 | 5 | 5 |
| Terminals | 4 | 5 | 9 |
| Editors | 6 | 9 | 15 |
| Development | 10 | 8 | 18 |
| Security | 9 | 4 | 13 |
| Networking | 12 | 8 | 20 |
| Multimedia | 12 | 3 | 15 |
| Productivity | 4 | 5 | 9 |
| System | 45 | 20 | 65 |
| AI | 2 | 5 | 7 |
| **Total** | **104** | **72** | **176** |

### 15.2 Desktop Environment Summary

| Desktop | Protocol | Bar | Launcher | Notification |
| ------- | -------- | --- | -------- | ------------ |
| GNOME | Wayland | GNOME Shell | GNOME | GNOME |
| COSMIC | Wayland | cosmic-panel | cosmic-launcher | cosmic-notifications |
| Niri | Wayland | Ironbar | onagre/anyrun | wired |
| LeftWM | X11 | Polybar | rlaunch/rofi | dunst |

---

<!-- markdownlint-disable-next-line MD036 -->
*─── Forged in Steelbore ───*
