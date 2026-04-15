# Lattice Implementation TODO

This document tracks the implementation status of the Lattice NixOS distribution based on the [Product Requirements Document (PRD.md)](./PRD.md) v3.0.

---

## Phase 1: Foundation & Structure

- [x] Establish git repository structure
- [x] Create `flake.nix` entry point with all inputs
- [x] Configure stable nixpkgs (`nixos-25.11`)
- [x] Configure unstable nixpkgs channel (`nixos-unstable`)
- [x] Configure home-manager input (stable `release-25.11`, follows nixpkgs)
- [x] Configure home-manager-unstable input (follows nixpkgs-unstable)
- [x] Configure nix-flatpak input
- [x] Define `mkLattice` function with `marchLevel` and `channel` parameters
- [x] Generate 10 `nixosConfigurations` (5 stable + 5 unstable, v1-v4 each)
- [x] Set up `steelborePalette` in specialArgs
- [x] ~~Pass `stablePkgs` to modules via specialArgs~~ (removed — claude-code now uses channel-appropriate `pkgs`)
- [x] Build folder hierarchy (`hosts/`, `modules/`, `lib/`, `users/`, `overlays/`)

---

## Phase 2: Core Modules (`modules/core/`)

- [x] **`default.nix`**: Core module entry point with imports
- [x] **`boot.nix`**: systemd-boot configuration, EFI variables writable
- [x] **`boot.nix`**: XanMod kernel (`linuxPackages_xanmod_latest`)
- [x] **`boot.nix`**: initrd modules (`xhci_pci`, `nvme`, `usb_storage`, `sd_mod`, `rtsx_pci_sdmmc`)
- [x] **`boot.nix`**: Kernel modules (`kvm-intel`)
- [x] **`nix.nix`**: Enable flakes and nix-command
- [x] **`nix.nix`**: Configure garbage collection (weekly, 30d retention)
- [x] **`nix.nix`**: Allow unfree packages
- [x] **`nix.nix`**: Load overlays (claude-code, sequoia-wot)
- [x] **`locale.nix`**: Set timezone to `Asia/Bahrain`
- [x] **`locale.nix`**: Configure `en_US.UTF-8` locale (all `LC_*` variables)
- [x] **`locale.nix`**: Console keymap (`us`)
- [x] **`audio.nix`**: Disable PulseAudio
- [x] **`audio.nix`**: Enable PipeWire with ALSA/Pulse compatibility
- [x] **`audio.nix`**: Enable rtkit for realtime audio
- [x] **`security.nix`**: Disable standard sudo
- [x] **`security.nix`**: Enable sudo-rs (Rust), `execWheelOnly = true`
- [x] **`security.nix`**: Enable polkit
- [x] **`security.nix`**: Enable SSH agent, disable GNOME keyring SSH agent
- [x] **`security.nix`**: Configure tmpfiles rules (`/tmp`, `/var/tmp`)

---

## Phase 3: Theme Engine (`modules/theme/`)

- [x] **`default.nix`**: Define `STEELBORE_*` environment variables (6 colors)
- [x] **`default.nix`**: Configure TTY console colors (16-color palette)
- [x] **`fonts.nix`**: Install Orbitron (UI headers)
- [x] **`fonts.nix`**: Install JetBrains Mono (code/terminal)
- [x] **`fonts.nix`**: Install Nerd Fonts variants (JetBrains Mono, CaskaydiaMono)
- [x] **`fonts.nix`**: Install Share Tech Mono (HUD/data)
- [x] **`fonts.nix`**: Configure fontconfig defaults (monospace, sans-serif, serif)

---

## Phase 4: Login Management (`modules/login/`)

- [x] **`default.nix`**: greetd + tuigreet with Steelbore branding
- [x] **`default.nix`**: Session memory and ISO 8601 time display
- [x] **`default.nix`**: Shell sessions (Ion, Nushell, Brush) via `mkShellSession`
- [x] **`default.nix`**: Register session packages (niri, cosmic, ion, nushell, brush)
- [x] **`default.nix`**: PAM gnome-keyring integration

---

## Phase 5: Desktop Environments (`modules/desktops/`)

### GNOME (`gnome.nix`)

- [x] Define `steelbore.desktops.gnome` option
- [x] Enable GNOME on Wayland, disable GDM (use greetd)
- [x] Install GNOME Tweaks, dconf-editor
- [x] Install extension manager and browser connector
- [x] Install curated extensions (14: Caffeine, Just Perfection, Forge, etc.)
- [x] Configure XDG portals (gnome, gtk)
- [x] Exclude bloatware (Tour, Music, Epiphany, Geary, Totem)

### COSMIC (`cosmic.nix`)

- [x] Define `steelbore.desktops.cosmic` option
- [x] Enable COSMIC DE, disable cosmic-greeter (use greetd)

### KDE Plasma 6 (`plasma.nix`)

- [x] Define `steelbore.desktops.plasma` option
- [x] Enable Plasma 6 on Wayland, disable SDDM (use greetd)
- [x] Enable X server for XWayland support
- [x] Configure SSH askpass override (`ksshaskpass`)
- [x] Install KDE packages (8: browser-integration, kdeconnect, systemmonitor, etc.)
- [x] Enable KWallet and Krohnkite tiling
- [x] Enable GPG agent with pinentry-qt
- [x] Exclude bloatware (oxygen, elisa, khelpcenter)

### Niri (`niri.nix`) -- The Steelbore Standard

- [x] Define `steelbore.desktops.niri` option
- [x] Enable Niri compositor
- [x] Install companion packages (14: swaybg, xwayland-satellite, ironbar, waybar, etc.)
- [x] Write `/etc/niri/config.kdl` with Steelbore palette
- [x] Write `/etc/ironbar/config.yaml` and `/etc/ironbar/style.css`
- [x] Configure keybindings (Vim-style + CUA arrows); `Mod+Return` → rio (default terminal)
- [x] Configure workspaces 1-5
- [x] Configure startup applications (swaybg, ironbar, wired)
- [x] Configure input (keyboard `us,ar` with `grp:ctrl_space_toggle`, touchpad)

### LeftWM (`leftwm.nix`)

- [x] Define `steelbore.desktops.leftwm` option
- [x] Enable X11 and LeftWM, configure XKB layout (`us,ar`)
- [x] Install companion packages (15: rlaunch, rofi, dmenu, polybar, picom, etc.)
- [x] Write `/etc/leftwm/config.ron` with keybindings; `Mod+Return` → rio (default terminal)
- [x] Write theme files (`theme.ron`, `up`, `down`, `polybar.ini`, `template.liquid`, `picom.conf`)
- [x] Write `/etc/dunst/dunstrc` with Steelbore theme

---

## Phase 6: Package Modules (`modules/packages/`)

### Infrastructure

- [x] **`default.nix`**: Package module entry with imports (all 12 submodules)

### browsers.nix

- [x] Define `steelbore.packages.browsers` option
- [x] Enable Firefox via `programs.firefox`
- [x] Install browsers (Chrome, Brave, Edge, Librewolf)

### terminals.nix

- [x] Define `steelbore.packages.terminals` option
- [x] Install Rust terminals (Alacritty, WezTerm, Rio, Warp)
- [x] Install Ghostty (Zig)
- [x] Install GTK/VTE terminals (Ptyxis, GNOME Console)
- [x] Install AI-native terminals (WaveTerm)
- [x] Install KDE terminals (Konsole, Yakuake)
- [x] Install other terminals (Foot, XTerm, XFCE4 Terminal, Termius, COSMIC Term)
- [x] Write system-level configs for all 15 terminals with Steelbore theme

### editors.nix

- [x] Define `steelbore.packages.editors` option
- [x] Install linting (markdownlint-cli2)
- [x] Install Rust TUI editors (Helix, Amp, msedit)
- [x] Install standard TUI editors (Neovim, Vim, mg, mc)
- [x] Install Rust GUI editors (Zed, Lapce, Neovide, cosmic-edit)
- [x] Install standard GUI editors (Emacs-pgtk, VSCode-FHS, gedit)

### development.nix

- [x] Define `steelbore.packages.development` option
- [x] Install Git and Rust VCS tools (gitui, delta, jujutsu)
- [x] Install gh and github-desktop
- [x] Install Rust toolchain (rustup, cargo, cargo-update)
- [x] Install build tools (just, sad, pueue, tokei)
- [x] Install environment tools (lorri, dotter)
- [x] Install languages (JDK, PHP)
- [x] Install Nix ecosystem (nixfmt, cachix, nix, guix)
- [x] Configure system Git defaults (`init.defaultBranch`, `core.editor`)

### security.nix

- [x] Define `steelbore.packages.security` option
- [x] Install Rust encryption (age, rage)
- [x] Install sops for secrets
- [x] Install Sequoia PGP stack (sq, chameleon, wot, sqv, sqop)
- [x] Install password managers (rbw, bitwarden-cli/desktop, authenticator)
- [x] Install SSH tools (openssh_hpn)
- [x] Install pika-backup (Rust, Borg frontend)
- [x] Install sydbox (process sandboxing)
- [x] Install sbctl (Secure Boot)

### networking.nix

- [x] Define `steelbore.packages.networking` option
- [x] Install network management (impala, iwd)
- [x] Install HTTP clients (xh, monolith, curlFull, wget2)
- [x] Install Rust diagnostics (gping, trippy, lychee, rustscan, sniffglue, bandwhich)
- [x] Install GUI tools (sniffnet, mullvad-vpn, rqbit)
- [x] Install download managers (aria2, uget)
- [x] Install clipboard tools (wl-clipboard, wl-clipboard-rs)
- [x] Install DNS & services (dnsmasq, atftp, adguardhome)

### multimedia.nix

- [x] Define `steelbore.packages.multimedia` option
- [x] Install video players (mpv, vlc, cosmic-player)
- [x] Install Rust audio (amberol, termusic, ncspot, psst, shortwave)
- [x] Install Rust image viewers (loupe, viu, emulsion)
- [x] Install mousai (audio recognition)
- [x] Install processing tools (rav1e, gifski, oxipng, video-trimmer, ffmpeg)
- [x] Install yt-dlp

### productivity.nix

- [x] Define `steelbore.packages.productivity` option
- [x] Install Rust knowledge tools (AppFlowy, Affine)
- [x] Install office suites (LibreOffice, OnlyOffice)
- [x] Install utilities (qalculate-gtk)
- [x] Install communication (Fractal, NewsFlash, Tutanota, Onedriver)

### system.nix

- [x] Define `steelbore.packages.system` option
- [x] Install modern Unix (fd, ripgrep, bat, eza, sd, zoxide, procs, dust, dua)
- [x] Install uutils (coreutils, diffutils, findutils)
- [x] Install file managers (yazi, broot, superfile, spacedrive, fclones, kondo, pipe-rename, ouch)
- [x] Install disk tools (gptman)
- [x] Install monitoring (bottom, kmon, macchina, bandwhich, mission-center, htop, btop, gotop, fastfetch, i7z, hw-probe)
- [x] Install text processing (jaq, teip, htmlq, skim, tealdeer, mdcat, difftastic)
- [x] Install Rust shells (nushell, brush, ion, starship, atuin, pipr, moor, powershell)
- [x] Install multiplexers (zellij, screen)
- [x] Install t-rec (terminal recorder)
- [x] Install containers (distrobox, boxbuddy, host-spawn, podman, runc, youki, oxker, qemu, flatpak, bubblewrap)
- [x] Install system management (topgrade, paru, doas, os-prober, kbd, numlockx, xremap, input-leap)
- [x] Install archiving (p7zip, zip, unzip)
- [x] Install ZFS tools and antigravity
- [x] Install benchmarking (phoronix-test-suite, perf)
- [x] Enable Flatpak and AppImage (binfmt) services
- [x] Enable Podman with `dockerCompat`, runc + youki runtimes

### ai.nix

- [x] Define `steelbore.packages.ai` option
- [x] Install Rust AI tools (aichat, gemini-cli)
- [x] Install opencode (Go)
- [x] Install AI tools (codex, copilot-cli, gpt-cli, mcp-nixos)
- [x] Install task-master-ai
- [x] Install claude-code from channel-appropriate `pkgs` (stable on stable, unstable on unstable)

### flatpak.nix

- [x] Define `steelbore.packages.flatpak` option
- [x] Configure Flathub remote
- [x] Declare Flatpak packages (60+ apps across terminals, browsers, communication, security, development, gaming, retro, productivity)

---

## Phase 7: Hardware Modules (`modules/hardware/`)

- [x] **`default.nix`**: Hardware module entry point (imports fingerprint, intel)
- [x] **`fingerprint.nix`**: Define option, enable fprintd
- [x] **`intel.nix`**: Define option with `marchLevel` suboption (enum: v1/v2/v3/v4, default: v4)
- [x] **`intel.nix`**: Enable `kvm-intel` module, Intel microcode updates
- [x] **`intel.nix`**: Set per-level optimization flags (CFLAGS, CXXFLAGS, RUSTFLAGS, GOAMD64, LDFLAGS, LTOFLAGS)
- [x] **`intel.nix`**: v1/v3/v4 CachyOS-sourced flags, v2 ALHP-sourced flags

---

## Phase 8: Host & User Configuration

### Host (`hosts/lattice/`)

- [x] **`default.nix`**: Set hostname to `lattice`
- [x] **`default.nix`**: Enable NetworkManager
- [x] **`default.nix`**: Configure X11 keyboard layout (`us,ara`, `grp:ctrl_space_toggle`)
- [x] **`default.nix`**: Console keymap `us`
- [x] **`default.nix`**: Enable printing
- [x] **`default.nix`**: Create user `mj` with groups (networkmanager, wheel, input, video, audio)
- [x] **`default.nix`**: Set user shell to Nushell (Rust), root shell to Brush (Rust)
- [x] **`default.nix`**: Register Nushell, Brush, Ion as valid login shells; bash disabled (`programs.bash.enable = false`)
- [x] **`default.nix`**: Enable all steelbore desktop modules (gnome, cosmic, plasma, niri, leftwm)
- [x] **`default.nix`**: Enable all steelbore hardware modules (fingerprint, intel)
- [x] **`default.nix`**: Enable all steelbore package modules (12 modules including flatpak)
- [x] **`default.nix`**: Set `stateVersion = "25.11"`
- [x] **`hardware.nix`**: Import from `modulesPath`, configure root (ext4) and boot (vfat) filesystems

### User (`users/mj/`)

- [x] **`default.nix`**: Define user account
- [x] **`home.nix`**: Set username, home directory, stateVersion 25.11
- [x] **`home.nix`**: Create `~/steelbore` symlink to `/steelbore`
- [x] **`home.nix`**: Configure keyboard layout (`us,ara`, `grp:ctrl_space_toggle`)
- [x] **`home.nix`**: Set session variables (`EDITOR`, `VISUAL` to msedit, `STEELBORE_THEME`)
- [x] **`home.nix`**: Configure Git with SSH signing (Sequoia), LFS enabled
- [x] **`home.nix`**: Configure Starship prompt (Tokyo Night preset)
- [x] **`home.nix`**: Configure Nushell with aliases (telemetry, steelbore banner)
- [x] **`home.nix`**: Configure Ion shell init (`~/.config/ion/initrc`) with aliases
- [x] **`home.nix`**: Configure Alacritty with Steelbore colors (via `programs.alacritty`)
- [x] **`home.nix`**: Write user-level XDG configs (niri, ironbar, wezterm, rio, ghostty, foot, xfce4-terminal, konsole, yakuake, xresources)
- [x] **`home.nix`**: Configure dconf settings (Ptyxis profile, GNOME Console)
- [x] **`home.nix`**: Configure containers (`~/.config/containers/containers.conf`, runc default)

---

## Phase 9: Overlays (`overlays/default.nix`)

- [x] **sequoia-wot**: Disable failing tests (`doCheck = false`)
- [x] **sequoia-wot**: Disable failing tests (`doCheck = false`)
- [x] ~~**claude-code**: Custom overlay~~ (removed — uses standard nixpkgs package)

---

## Phase 10: Testing & Verification

- [x] Run `nix flake check` without errors
- [x] Run `nix flake show` and verify 10 configurations listed
- [x] Run `nixos-rebuild dry-build --flake .#lattice` successfully
- [x] Run `nixos-rebuild build --flake .#lattice` successfully
- [x] Run `nixos-rebuild switch --flake .#lattice` successfully
- [x] Verify march-level variant build (`nixos-rebuild build --flake .#lattice-v3`)
- [x] Verify unstable channel build (`nixos-rebuild build --flake .#lattice-unstable`)
- [~] Verify Niri session boots with Ironbar
- [x] Verify COSMIC session boots with panel
- [x] Verify GNOME session boots on Wayland
- [x] Verify KDE Plasma 6 session boots on Wayland
- [ ] Verify LeftWM session boots with Polybar
- [x] Verify greetd/tuigreet login with session selection
- [x] Verify Steelbore palette on TTY
- [~] Verify Steelbore palette on all themed terminals (15)
- [ ] Verify Steelbore palette on Ironbar and Polybar
- [ ] Verify sudo-rs works for privilege escalation
- [x] Verify fingerprint authentication (fprintd)
- [ ] Verify Podman with `docker` compat alias
- [x] Verify Flatpak apps install from Flathub
- [ ] Verify AppImage binfmt execution

---

## Phase 11: Documentation

- [x] **README.md**: Project overview and quick start
- [x] **ARCHITECTURE.md**: System diagrams and data flow
- [x] **TODO.md**: Implementation checklist (this file)
- [x] **PRD.md**: Product requirements (v3.0)

---

## Known Issues & Notes

1. **COSMIC packages**: Uses native nixpkgs module (no third-party flake). `useFetchCargoVendor` deprecation warnings come from upstream nixpkgs packages — harmless.

2. **claude-code**: Uses standard nixpkgs package (`pkgs.claude-code`), channel-appropriate (stable on stable, unstable on unstable).

3. **XanMod kernel**: Sourced from unstable channel for latest version.

4. **sequoia-wot**: Tests disabled via overlay due to build failures.

5. **Console keymap**: Set to `us` only -- ckbcomp can't resolve multi-layout XKB configs (`us,ara`).

---

## Summary

| Phase | Status | Progress |
|-------|--------|----------|
| 1. Foundation | Complete | 12/12 |
| 2. Core Modules | Complete | 20/20 |
| 3. Theme Engine | Complete | 7/7 |
| 4. Login Management | Complete | 5/5 |
| 5. Desktop Environments | Complete | 33/33 |
| 6. Package Modules | Complete | 72/72 |
| 7. Hardware Modules | Complete | 6/6 |
| 8. Host & User Config | Complete | 26/26 |
| 9. Overlays | Complete | 2/2 |
| 10. Testing | In Progress | 2/21 |
| 11. Documentation | Complete | 4/4 |
| **Total** | **91%** | **189/208** |

---

*Last updated: 2026-04-14*
