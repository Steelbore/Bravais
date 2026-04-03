# Lattice Implementation TODO

This document tracks the implementation status of the Lattice NixOS distribution based on the [Product Requirements Document (PRD.md)](./PRD.md).

---

## Phase 1: Foundation & Structure

- [x] Establish git repository structure
- [x] Create `flake.nix` entry point with all inputs
- [x] Configure stable nixpkgs (25.11)
- [x] Configure unstable nixpkgs channel
- [x] Configure home-manager input
- [x] Configure nixos-cosmic input
- [x] Configure emacs-ng input
- [x] Define `nixosConfigurations.lattice` output
- [x] Set up `steelborePalette` in specialArgs
- [x] Pass `unstable` to modules via specialArgs
- [x] Build folder hierarchy (`hosts/`, `modules/`, `lib/`, `users/`, `overlays/`)

---

## Phase 2: Core Modules (`modules/core/`)

- [x] **`default.nix`**: Core module entry point with imports
- [x] **`boot.nix`**: systemd-boot configuration
- [x] **`boot.nix`**: XanMod kernel from unstable (`linuxPackages_xanmod_latest`)
- [x] **`boot.nix`**: initrd kernel modules (xhci_pci, nvme, usb_storage, sd_mod)
- [x] **`nix.nix`**: Enable flakes and nix-command
- [x] **`nix.nix`**: Configure garbage collection (weekly, 30d retention)
- [x] **`nix.nix`**: Allow unfree packages
- [x] **`nix.nix`**: Configure COSMIC binary cache
- [x] **`locale.nix`**: Set timezone to UTC
- [x] **`locale.nix`**: Configure en_US.UTF-8 locale
- [x] **`locale.nix`**: Console XKB configuration
- [x] **`audio.nix`**: Disable PulseAudio
- [x] **`audio.nix`**: Enable PipeWire with ALSA/Pulse compatibility
- [x] **`audio.nix`**: Enable rtkit for realtime audio
- [x] **`security.nix`**: Disable standard sudo
- [x] **`security.nix`**: Enable sudo-rs (Rust implementation)
- [x] **`security.nix`**: Enable polkit
- [x] **`security.nix`**: Configure tmpfiles rules

---

## Phase 3: Theme Engine (`modules/theme/`)

- [x] **`default.nix`**: Define STEELBORE_* environment variables
- [x] **`default.nix`**: Configure TTY console colors (16-color palette)
- [x] **`fonts.nix`**: Install Orbitron (UI headers)
- [x] **`fonts.nix`**: Install JetBrains Mono (code/terminal)
- [x] **`fonts.nix`**: Install Cascadia Code (fallback)
- [x] **`fonts.nix`**: Install Nerd Fonts variants
- [x] **`fonts.nix`**: Install Share Tech Mono (HUD/data)
- [x] **`fonts.nix`**: Configure fontconfig defaults

---

## Phase 4: Login Management (`modules/login/`)

- [x] **`default.nix`**: Login module entry point
- [x] **`greetd.nix`**: Enable greetd service
- [x] **`greetd.nix`**: Configure tuigreet with session memory
- [x] **`greetd.nix`**: Default to Niri session
- [x] **`greetd.nix`**: Create session selector script
- [x] **`greetd.nix`**: Install lemurs alternative

---

## Phase 5: Desktop Environments (`modules/desktops/`)

### GNOME (`gnome.nix`)
- [x] Define `steelbore.desktops.gnome` option
- [x] Enable GNOME on Wayland
- [x] Disable GDM (use greetd instead)
- [x] Install GNOME Tweaks, dconf-editor
- [x] Install extension manager and connector
- [x] Install curated extensions (Caffeine, Just Perfection, etc.)
- [x] Configure XDG portals
- [x] Exclude bloatware (Tour, Music, Epiphany, Geary, Totem)

### COSMIC (`cosmic.nix`)
- [x] Define `steelbore.desktops.cosmic` option
- [x] Enable COSMIC from nixos-cosmic flake
- [x] Disable cosmic-greeter (use greetd)
- [x] Install core COSMIC packages (session, comp, bg, osd)
- [x] Install panel and applets
- [x] Install COSMIC applications (term, edit, files, store)
- [x] Install COSMIC extensions
- [x] Configure XDG portal

### Niri (`niri.nix`) — *The Steelbore Standard*
- [x] Define `steelbore.desktops.niri` option
- [x] Enable Niri compositor
- [x] Install companion packages (swaybg, xwayland-satellite)
- [x] Install ironbar (Rust status bar)
- [x] Install anyrun from unstable
- [x] Install onagre launcher
- [x] Install wired notifications (Rust)
- [x] Install swaylock/swayidle
- [x] Install clipboard tools (wl-clipboard, wl-clipboard-rs)
- [x] Install screenshot tools (grim, slurp)
- [x] Write `/etc/niri/config.kdl` with Steelbore palette
- [x] Write `/etc/ironbar/config.yaml`
- [x] Write `/etc/ironbar/style.css` with Steelbore theme
- [x] Configure keybindings (Vim-style + arrows)
- [x] Configure workspaces 1-5
- [x] Configure startup applications

### LeftWM (`leftwm.nix`)
- [x] Define `steelbore.desktops.leftwm` option
- [x] Enable X11 and LeftWM
- [x] Configure XKB layout (us,ar)
- [x] Install LeftWM packages (leftwm, leftwm-theme, leftwm-config)
- [x] Install rlaunch from unstable
- [x] Install rofi and dmenu
- [x] Install polybar
- [x] Install picom compositor
- [x] Install utilities (feh, dunst, xclip, maim, xdotool)
- [x] Write `/etc/leftwm/config.ron` with keybindings
- [x] Write `/etc/leftwm/themes/current/theme.ron` with Steelbore colors
- [x] Write `/etc/leftwm/themes/current/up` startup script
- [x] Write `/etc/leftwm/themes/current/down` shutdown script
- [x] Write `/etc/leftwm/themes/current/polybar.ini` with Steelbore theme
- [x] Write `/etc/leftwm/themes/current/template.liquid` for tags
- [x] Write `/etc/leftwm/themes/current/picom.conf`
- [x] Write `/etc/dunst/dunstrc` with Steelbore theme

---

## Phase 6: Package Modules (`modules/packages/`)

### Infrastructure
- [x] **`default.nix`**: Package module entry with imports

### browsers.nix
- [x] Define `steelbore.packages.browsers` option
- [x] Enable Firefox via programs.firefox
- [x] Install browsers from unstable (Chrome, Brave, Edge, Librewolf)

### terminals.nix
- [x] Define `steelbore.packages.terminals` option
- [x] Install Rust terminals (Alacritty, WezTerm, Rio)
- [x] Install Ghostty (Zig, memory-safe)
- [x] Install unstable terminals (ptyxis, waveterm, warp-terminal)
- [x] Install Termius and cosmic-term
- [x] Write `/etc/alacritty/alacritty.toml` with Steelbore theme
- [x] Write `/etc/wezterm/wezterm.lua` with Steelbore theme
- [x] Write `/etc/rio/config.toml` with Steelbore theme

### editors.nix
- [x] Define `steelbore.packages.editors` option
- [x] Install Rust TUI editors (Helix, Amp, msedit)
- [x] Install standard TUI editors (Neovim, Vim, mg, mc)
- [x] Install Rust GUI editors (Zed, Lapce, Neovide, cosmic-edit)
- [x] Install standard GUI editors (Emacs-ng, VSCode, VSCodium, Cursor)

### development.nix
- [x] Define `steelbore.packages.development` option
- [x] Install Git and Rust tools (gitui, delta, jujutsu)
- [x] Install gh from unstable
- [x] Install Rust toolchain (rustup, cargo)
- [x] Install build tools (just, sad, pueue, tokei)
- [x] Install environment tools (lorri, dotter)
- [x] Install languages (JDK, PHP)
- [x] Install Nix ecosystem (nixfmt, cachix, guix)
- [x] Configure system Git defaults

### security.nix
- [x] Define `steelbore.packages.security` option
- [x] Install Rust encryption (age, rage)
- [x] Install sops for secrets
- [x] Install Sequoia PGP stack (sq, chameleon, wot, sqv, sqop)
- [x] Install password managers (rbw, bitwarden-cli/desktop from unstable)
- [x] Install authenticator (Rust 2FA)
- [x] Install SSH tools
- [x] Install pika-backup from unstable
- [x] Install sbctl (Secure Boot)

### networking.nix
- [x] Define `steelbore.packages.networking` option
- [x] Install network management (impala, iwd)
- [x] Install HTTP clients (xh, monolith, curl, wget2)
- [x] Install Rust diagnostics (gping, trippy, lychee, rustscan)
- [x] Install GUI tools (sniffnet, mullvad-vpn, rqbit from unstable)
- [x] Install download managers (aria2, uget)
- [x] Install DNS tools (dnsmasq, adguardhome)

### multimedia.nix
- [x] Define `steelbore.packages.multimedia` option
- [x] Install video players (mpv, vlc, cosmic-player)
- [x] Install Rust audio (amberol, termusic, ncspot, psst, shortwave)
- [x] Install Rust image viewers (loupe, viu, emulsion)
- [x] Install mousai (audio recognition)
- [x] Install processing tools (rav1e, gifski, oxipng, gyroflow)
- [x] Install ffmpeg and yt-dlp

### productivity.nix
- [x] Define `steelbore.packages.productivity` option
- [x] Install Rust knowledge tools (AppFlowy, Affine)
- [x] Install office suites (LibreOffice, OnlyOffice)
- [x] Install Rust communication (iamb, fractal, newsflash)
- [x] Install tutanota-desktop from unstable
- [x] Install onedriver

### system.nix
- [x] Define `steelbore.packages.system` option
- [x] Install modern Unix (fd, ripgrep, bat, eza, sd, zoxide, procs, dust, dua)
- [x] Install uutils (coreutils, diffutils, findutils)
- [x] Install file managers (yazi, broot, superfile, spacedrive from unstable)
- [x] Install disk tools (disktui from unstable, gptman)
- [x] Install monitoring (bottom, kmon, macchina, bandwhich, mission-center)
- [x] Install standard monitoring (htop, btop, gotop, fastfetch)
- [x] Install text processing (jaq, teip, htmlq, skim, tealdeer, mdcat, difftastic)
- [x] Install Rust shells (nushell, brush, ion, starship, atuin, pipr)
- [x] Install moor and powershell from unstable
- [x] Install multiplexers (zellij, screen)
- [x] Install t-rec (terminal recorder)
- [x] Install containers (distrobox, boxbuddy, qemu, flatpak)
- [x] Install system management (topgrade, paru, doas, xremap)
- [x] Install archiving (p7zip, zip, unzip, ouch)
- [x] Install ZFS tools and antigravity from unstable
- [x] Install benchmarking tools
- [x] Enable Flatpak service

### ai.nix
- [x] Define `steelbore.packages.ai` option
- [x] Install Rust AI tools (aichat, gemini-cli)
- [x] Install opencode
- [x] Install unstable AI tools (codex, copilot-cli, gpt-cli, mcp-nixos)
- [x] Install claude-code from **stable** (not unstable, due to issues)

---

## Phase 7: Hardware Modules (`modules/hardware/`)

- [x] **`default.nix`**: Hardware module entry point
- [x] **`fingerprint.nix`**: Define option and enable fprintd
- [x] **`intel.nix`**: Define option
- [x] **`intel.nix`**: Enable kvm-intel module
- [x] **`intel.nix`**: Configure microcode updates
- [x] **`intel.nix`**: Set x86-64-v4 optimization flags (RUSTFLAGS, CFLAGS, etc.)

---

## Phase 8: Host & User Configuration

### Host (`hosts/lattice/`)
- [x] **`default.nix`**: Set hostname to "lattice"
- [x] **`default.nix`**: Enable NetworkManager
- [x] **`default.nix`**: Configure X11 keyboard layout
- [x] **`default.nix`**: Enable printing
- [x] **`default.nix`**: Create user "mj" with groups
- [x] **`default.nix`**: Set shell to nushell
- [x] **`default.nix`**: Enable all steelbore desktop modules
- [x] **`default.nix`**: Enable all steelbore hardware modules
- [x] **`default.nix`**: Enable all steelbore package modules
- [x] **`default.nix`**: Set stateVersion to 25.11
- [x] **`hardware.nix`**: Import from modulesPath
- [x] **`hardware.nix`**: Configure root filesystem (ext4, UUID)
- [x] **`hardware.nix`**: Configure boot filesystem (vfat, UUID)
- [x] **`hardware.nix`**: Set hostPlatform to x86_64-linux

### User (`users/mj/`)
- [x] **`default.nix`**: Define user account
- [x] **`home.nix`**: Set username and home directory
- [x] **`home.nix`**: Create steelbore symlink
- [x] **`home.nix`**: Configure keyboard layout
- [x] **`home.nix`**: Set session variables (EDITOR, VISUAL)
- [x] **`home.nix`**: Configure Git with GPG signing (Sequoia)
- [x] **`home.nix`**: Configure Starship with Steelbore palette
- [x] **`home.nix`**: Configure Nushell with aliases
- [x] **`home.nix`**: Configure Alacritty with Steelbore colors
- [x] **`home.nix`**: Write XDG config for Niri
- [x] **`home.nix`**: Write XDG config for Ironbar
- [x] **`home.nix`**: Write XDG config for WezTerm
- [x] **`home.nix`**: Write XDG config for Rio

---

## Phase 9: Overlays

- [x] **`overlays/default.nix`**: Create overlay file
- [x] **`overlays/default.nix`**: Disable sequoia-wot tests (build fix)

---

## Phase 10: Testing & Verification

- [ ] Run `nix flake check` without errors
- [ ] Run `nixos-rebuild dry-build --flake .#lattice` successfully
- [ ] Run `nixos-rebuild build --flake .#lattice` successfully
- [ ] Run `nixos-rebuild switch --flake .#lattice` successfully
- [ ] Verify Niri session boots and displays correctly
- [ ] Verify COSMIC session boots and displays correctly
- [ ] Verify GNOME session boots and displays correctly
- [ ] Verify LeftWM session boots and displays correctly
- [ ] Verify greetd/tuigreet login works
- [ ] Verify Steelbore palette applies to TTY
- [ ] Verify Steelbore palette applies to Alacritty
- [ ] Verify Steelbore palette applies to Ironbar
- [ ] Verify Steelbore palette applies to Polybar
- [ ] Verify sudo-rs works for privilege escalation
- [ ] Verify fingerprint authentication works

---

## Phase 11: Documentation

- [x] **README.md**: Project overview and quick start
- [x] **ARCHITECTURE.md**: System diagrams and data flow
- [x] **TODO.md**: Implementation checklist (this file)
- [x] **PRD.md**: Product requirements (reference document)

---

## Known Issues & Notes

1. **COSMIC packages**: Show `useFetchCargoVendor` deprecation warnings during flake check — these are harmless and come from the nixos-cosmic flake.

2. **claude-code**: Must use stable channel, not unstable — unstable version has build/runtime issues.

3. **XanMod kernel**: Sourced from unstable channel for latest version.

4. **sequoia-wot**: Tests disabled via overlay due to build failures.

---

## Summary

| Phase | Status | Progress |
|-------|--------|----------|
| 1. Foundation | Complete | 11/11 |
| 2. Core Modules | Complete | 17/17 |
| 3. Theme Engine | Complete | 7/7 |
| 4. Login Management | Complete | 5/5 |
| 5. Desktop Environments | Complete | 48/48 |
| 6. Package Modules | Complete | 63/63 |
| 7. Hardware Modules | Complete | 6/6 |
| 8. Host & User Config | Complete | 25/25 |
| 9. Overlays | Complete | 2/2 |
| 10. Testing | Pending | 0/15 |
| 11. Documentation | Complete | 4/4 |
| **Total** | **93%** | **188/203** |

---

*Last updated: 2026-04-03*
