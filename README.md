# Steelbore Lattice

Lattice is a meticulously crafted, flake-based NixOS configuration implementing the **Steelbore Standard**. Designed from the ground up to be modular, memory-safe, and visually cohesive, it provides a performant, reliable, and highly customizable system architecture for advanced computing workflows.

## Core Philosophy

The design of Lattice is guided by four primary tenets:

1. **Rust-First Ecosystem (Memory Safety):** Extreme priority is given to tools written in memory-safe languages. Lattice replaces legacy C-based utilities with robust Rust equivalents—ranging from core privilege escalation (`sudo-rs` completely replacing standard `sudo`) to terminal emulators, status bars (`ironbar`), and application launchers (`anyrun`, `onagre`).

2. **Opt-in Modularity:** Every feature, hardware profile, and application set is structurally siloed inside its own module using Nix's `lib.mkEnableOption`. Hosts boot only exactly what they explicitly declare via the `steelbore.*` namespace.

3. **The Steelbore Telemetry Palette:** Color is treated as telemetry, not just decoration. A strict, universal 6-color *Steelbore Color Palette* acts as a system-wide visual identity unifying the interface—extending from desktop environments down to TTY consoles.

4. **Self-Sufficient Configuration:** Built with determinism and reproducibility at the forefront. Features minimal external dependencies beyond `nixpkgs`, ensuring your host builds identically every time.

## Directory Structure

```
lattice/
├── flake.nix                      # Flake entry point
├── flake.lock                     # Pinned dependencies
├── lib/                           # Custom Nix helper functions
│   └── default.nix                # Color palette definitions
├── hosts/                         # Machine-specific configurations
│   └── lattice/                   # Primary host
│       ├── default.nix            # Host traits & module toggles
│       └── hardware.nix           # Hardware configuration
├── modules/                       # NixOS modules (steelbore.* namespace)
│   ├── core/                      # Always-enabled necessities
│   │   ├── default.nix            # Core module entry
│   │   ├── nix.nix                # Nix settings, flakes, overlays
│   │   ├── boot.nix               # Bootloader, XanMod kernel
│   │   ├── locale.nix             # Timezone (UTC), i18n
│   │   ├── audio.nix              # PipeWire audio stack
│   │   └── security.nix           # sudo-rs, polkit
│   ├── theme/                     # Steelbore visual identity
│   │   ├── default.nix            # Color palette, TTY colors
│   │   └── fonts.nix              # Typography (Orbitron, JetBrains Mono)
│   ├── hardware/                  # Hardware-specific modules
│   │   ├── default.nix            # Hardware module entry
│   │   ├── fingerprint.nix        # fprintd support
│   │   └── intel.nix              # Intel CPU optimizations (x86-64-v4)
│   ├── desktops/                  # Desktop environments (opt-in)
│   │   ├── default.nix            # Desktop module entry
│   │   ├── gnome.nix              # GNOME on Wayland (de-bloated)
│   │   ├── cosmic.nix             # COSMIC DE on Wayland
│   │   ├── niri.nix               # Niri + Ironbar (The Steelbore Standard)
│   │   └── leftwm.nix             # LeftWM + Polybar on X11
│   ├── login/                     # Display/login managers
│   │   ├── default.nix            # Login module entry
│   │   └── greetd.nix             # greetd + tuigreet
│   └── packages/                  # Application bundles (opt-in)
│       ├── default.nix            # Package module entry
│       ├── browsers.nix           # Web browsers
│       ├── terminals.nix          # Terminal emulators (Steelbore themed)
│       ├── editors.nix            # Text editors & IDEs
│       ├── development.nix        # Dev tools & languages
│       ├── security.nix           # Encryption & auth (Sequoia stack)
│       ├── networking.nix         # Network tools
│       ├── multimedia.nix         # Media players & processing
│       ├── productivity.nix       # Office & notes
│       ├── system.nix             # System utilities (modern Unix)
│       └── ai.nix                 # AI coding assistants
├── users/                         # User profiles
│   └── mj/                        # User "mj"
│       ├── default.nix            # System-level user config
│       └── home.nix               # Home Manager configuration
└── overlays/                      # Package overlays
    └── default.nix                # Custom derivations (sequoia-wot fix)
```

## Steelbore Color Palette

| Token          | Hex       | Role                           |
|----------------|-----------|--------------------------------|
| Void Navy      | `#000027` | Background / Canvas            |
| Molten Amber   | `#D98E32` | Primary Text / Active Readout  |
| Steel Blue     | `#4B7EB0` | Primary Accent / Structural    |
| Radium Green   | `#50FA7B` | Success / Safe Status          |
| Red Oxide      | `#FF5C5C` | Warning / Error Status         |
| Liquid Coolant | `#8BE9FD` | Info / Links                   |

**`#000027` (Void Navy) is the mandatory background for ALL Steelbore surfaces.**

## Desktop Environments

Lattice officially provisions definitions for four primary desktop targets:

| Desktop | Protocol | Status Bar | Launcher | Description |
|---------|----------|------------|----------|-------------|
| **Niri** | Wayland | Ironbar | onagre/anyrun | *The Steelbore Standard* — Scrolling tiling compositor |
| **COSMIC** | Wayland | cosmic-panel | cosmic-launcher | System76's fully Rust-based desktop |
| **GNOME** | Wayland | GNOME Shell | GNOME | De-bloated GNOME with curated extensions |
| **LeftWM** | X11 | Polybar | rlaunch/rofi | High-performance Rust tiling fallback |

## Flake Inputs

| Input | Channel | Purpose |
|-------|---------|---------|
| `nixpkgs` | 25.11 stable | Core package set |
| `nixpkgs-unstable` | unstable | Bleeding-edge packages |
| `home-manager` | release-25.11 | User environment management |
| `nixos-cosmic` | latest | COSMIC Desktop Environment |
| `emacs-ng` | latest | Enhanced Emacs with Rust/Deno |

## Host Configuration Pattern

Hosts toggle modules declaratively via the `steelbore.*` namespace:

```nix
{
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
}
```

## Quick Start

```bash
# Check the configuration validation
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

## Documentation

- [PRD.md](./PRD.md) — Product Requirements Document and module specifications
- [ARCHITECTURE.md](./ARCHITECTURE.md) — System architecture and data-flow diagrams
- [TODO.md](./TODO.md) — Implementation task tracking

## Package Statistics

| Category | Rust-First | Other | Total |
|----------|------------|-------|-------|
| System Utilities | 45 | 20 | 65 |
| Networking | 12 | 8 | 20 |
| Development | 10 | 8 | 18 |
| Multimedia | 12 | 3 | 15 |
| Editors | 6 | 9 | 15 |
| Security | 9 | 4 | 13 |
| Terminals | 4 | 5 | 9 |
| Productivity | 4 | 5 | 9 |
| AI | 2 | 5 | 7 |
| Browsers | 0 | 5 | 5 |
| **Total** | **104** | **72** | **176** |

---
*Lattice (A Steelbore NixOS Distribution)* | *Version 2.0*
