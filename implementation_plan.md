# Lattice : A Steelbore NixOS Distribution - Architecture Review & Rewrite Plan

## 1. Goal Description

The objective is to plan a full rewrite for a flake-based configuration of "Lattice", a Steelbore NixOS distribution. The rewrite must incorporate all packages, configurations, and settings currently defined in `/etc/nixos/lattice` while providing a robust, maintainable, and modular architecture. This plan serves as the foundation for the upcoming Product Requirements Document (PRD).

## 2. Critique of Current Architecture

The current architecture (as observed in `/etc/nixos/lattice` and related flake setups) has several structural and organizational issues:

- **Monolithic Host Configurations**: The host configuration (`hosts/lattice/default.nix` and `configuration.nix`) mixes hardware details, bootloader configurations, global system variables (like `RUSTFLAGS`), user definitions, display managers, and disparate settings. This lacks separation of concerns.
- **Redundancy and Cruft**: There is a redundant `configuration.nix` alongside `flake.nix` referencing modules and `hosts/lattice/default.nix`. It creates confusion about the true entry point of the configuration.
- **Package Management Sprawl**: While moving towards a categorized list is a good step (`modules/packages/categories.nix`), having over 120 packages managed centrally makes the configuration highly rigid. It doesn't allow easy toggling for minimal vs. full installs.
- **Tightly Coupled Modules**: The current module categorization (`gui`, `core`, `packages`) is largely hardcoded. The configuration relies on global imports rather than configurable NixOS modules using `lib.mkEnableOption` and `lib.mkIf`. This means including `gui/default.nix` enforces all defined GUIs simultaneously.
- **Home Manager Integration**: The `home.nix` is statically tied to the `mj` user within the host module, instead of separating user profiles from system-level configurations.

## 3. Proposed New Architecture (Flake-Based)

To solve these problems, we will reshape Lattice into a highly modular, composable, and scaleable NixOS Flake structure. The architectural philosophy is "Opt-in Everything."

### 3.1. Directory Structure

```text
lattice-os/
├── flake.nix                  # Flake entry point
├── flake.lock
├── lib/                       # Custom Nix helper functions
├── hosts/                     # Machine-specific configurations
│   ├── lattice/               # The 'lattice' host
│   │   ├── default.nix        # Host-specific traits (hostname, locale)
│   │   └── hardware.nix       # hardware-configuration from nixos-generate-config
│   └── iso/                   # Optional: ISO builder host
├── modules/                   # Custom NixOS and Home-Manager modules (The Core of Steelbore)
│   ├── core/                  # Always-enabled necessities (bootloader, nix settings)
│   ├── hardware/              # Hardware quirks (audio, bluetooth, fingerprint)
│   ├── desktops/              # Niri, COSMIC, LeftWM
│   ├── applications/          # Opt-in heavy apps or suites (browsers, editors, terminals)
│   ├── theme/                 # Implementation of the "Steelbore Color Palette"
│   └── security/              # Lanzaboote, sops/age, gpg, sudo-rs
├── users/                     # User-specific configurations
│   └── mj/                    # User "mj" profile
│       ├── default.nix        # System-level user definitions (shell, groups)
│       └── home/              # Home Manager definitions (dotfiles, user packages)
└── pkgs/                      # Custom derivations not in nixpkgs (if any)
```

### 3.2. Modular Design

Instead of dumping everything into a list, we use NixOS options (`lib.mkEnableOption`).

**Example: `modules/desktops/niri.nix`**
```nix
{ config, lib, pkgs, ... }:
{
  options.steelbore.desktops.niri.enable = lib.mkEnableOption "Enable Niri (The Steelbore Standard)";

  config = lib.mkIf config.steelbore.desktops.niri.enable {
    programs.niri.enable = true;
    services.displayManager.sessionPackages = [ pkgs.niri ];
    # Other Niri related packages (ironbar, etc.)
  };
}
```

This allows the host `lattice/default.nix` to look like this:
```nix
{
  steelbore = {
    desktops.niri.enable = true;
    desktops.cosmic.enable = true;
    hardware.fingerprint.enable = true;
    hardware.audio.enable = true;
    theme.colorscheme = "steelbore-default";
  };
}
```

### 3.3. Key Capabilities & Inclusions

- **Inputs Management**: Utilize `nixpkgs`, `cosmos`, `lanzaboote`, `home-manager` exactly as currently defined, but cleaner.
- **Packages & Settings Checklist (From `/lattice`)**:
  - **Core Settings:** `RUSTFLAGS`, `GOAMD64`, C/C++ build optimizations, `experimental-features`.
  - **Security:** `sudo-rs`, `lanzaboote` (secure boot), `fprintd` (fingerprint), OpenPGP suite (sequoia).
  - **DEs/WMs:** Niri, COSMIC DE, LeftWM.
  - **Login:** `greetd` with `tuigreet`.
  - **User Configuration:** Managed gracefully through standalone `users/mj` using `home-manager`.
  - **Theming:** Full integration of the 6-token "Steelbore Color Palette".

## 4. Migration Plan / Execution Strategy

To execute this rewrite during standard operations, we will:

1. **Scaffold the Flake Structure:** Create the new directory tree.
2. **Setup Core Library & Modules:** Implement the `lib/*.nix` helpers and create the foundational `modules/core/` and `modules/theme/` components.
3. **Migrate GUI/Desktops:** Port COSMIC, Niri, and LeftWM configurations into opt-in modules.
4. **Migrate Packages:** Break down the monolithic 14-category `categories.nix` into logical opt-in `modules/applications/` blocks (e.g., `applications.terminals`, `applications.browsers`).
5. **Migrate User Profile (`mj`):** Migrate `home.nix` and standard user configs into `users/mj/`.
6. **Host Assimilation:** Set up `hosts/lattice/default.nix` to cleanly toggle all options.
7. **Verification:** Evaluate `nix flake show` and run a dry-build `nixos-rebuild build --flake .#lattice --dry-run` to test the new code.

## 5. User Review Required

> [!IMPORTANT]
> The biggest shift in this architecture is moving from **imperative lists** (e.g., throwing packages into `environment.systemPackages`) to **declarative options** (`steelbore.application.browsers.enable = true`).
> Does this structure align with your vision for the Lattice PRD? Do you agree with creating custom NixOS options under a `steelbore.*` namespace?

## 6. Verification Plan

- **Automated Verification**: Use `nix flake check` and `# nix run nixpkgs#nixos-generators -- -f vm-nogui -c ./configuration.nix` (or equivalent test VM build) to ensure the configuration builds without errors. Note: Actual system tests will require VM building.
- **Manual Verification**: Since this is a system configuration, deploying a test iteration inside a VM or dry running the build locally (`nixos-rebuild dry-activate`) is necessary.
