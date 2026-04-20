# Lattice Implementation TODO

This document tracks the implementation status of the Lattice NixOS distribution based on the [Product Requirements Document (PRD.md)](./PRD.md) v3.0.

---

## Phase 1: Foundation & Structure

- [✓] Establish git repository structure
- [✓] Create `flake.nix` entry point with all inputs
- [✓] Configure stable nixpkgs (`nixos-25.11`)
- [✓] Configure unstable nixpkgs channel (`nixos-unstable`)
- [✓] Configure home-manager input (stable `release-25.11`, follows nixpkgs)
- [✓] Configure home-manager-unstable input (follows nixpkgs-unstable)
- [✓] Configure nix-flatpak input
- [✓] Define `mkLattice` function with `marchLevel` and `channel` parameters
- [✓] Generate 10 `nixosConfigurations` (5 stable + 5 unstable, v1-v4 each)
- [✓] Set up `steelborePalette` in specialArgs
- [✓] ~~Pass `stablePkgs` to modules via specialArgs~~ (removed — claude-code now uses channel-appropriate `pkgs`)
- [✓] Build folder hierarchy (`hosts/`, `modules/`, `lib/`, `users/`, `overlays/`)

---

## Phase 2: Core Modules (`modules/core/`)

- [✓] **`default.nix`**: Core module entry point with imports
- [✓] **`boot.nix`**: systemd-boot configuration, EFI variables writable
- [✓] **`boot.nix`**: XanMod kernel (`linuxPackages_xanmod_latest`)
- [✓] **`boot.nix`**: initrd modules (`xhci_pci`, `nvme`, `usb_storage`, `sd_mod`, `rtsx_pci_sdmmc`)
- [✓] **`boot.nix`**: Kernel modules (`kvm-intel`)
- [✓] **`nix.nix`**: Enable flakes and nix-command
- [✓] **`nix.nix`**: Configure garbage collection (weekly, 30d retention)
- [✓] **`nix.nix`**: Allow unfree packages
- [✓] **`nix.nix`**: Define overlays inline (sequoia-wot fix, claude-code pin to latest npm release)
- [✓] **`locale.nix`**: Set timezone to `Asia/Bahrain`
- [✓] **`locale.nix`**: Configure `en_US.UTF-8` locale (all `LC_*` variables)
- [✓] **`locale.nix`**: Console keymap (`us`)
- [✓] **`audio.nix`**: Disable PulseAudio
- [✓] **`audio.nix`**: Enable PipeWire with ALSA/Pulse compatibility
- [✓] **`audio.nix`**: Enable rtkit for realtime audio
- [✓] **`security.nix`**: Disable standard sudo
- [✓] **`security.nix`**: Enable sudo-rs (Rust), `execWheelOnly = true`
- [✓] **`security.nix`**: Enable polkit
- [✓] **`security.nix`**: Enable SSH agent, disable GNOME keyring SSH agent
- [✓] **`security.nix`**: Configure tmpfiles rules (`/tmp`, `/var/tmp`)

---

## Phase 3: Theme Engine (`modules/theme/`)

- [✓] **`default.nix`**: Define `STEELBORE_*` environment variables (6 colors)
- [✓] **`default.nix`**: Configure TTY console colors (16-color palette)
- [✓] **`fonts.nix`**: Install Orbitron (UI headers)
- [✓] **`fonts.nix`**: Install JetBrains Mono (code/terminal)
- [✓] **`fonts.nix`**: Install Nerd Fonts variants (JetBrains Mono, CaskaydiaMono)
- [✓] **`fonts.nix`**: Install Share Tech Mono (HUD/data)
- [✓] **`fonts.nix`**: Configure fontconfig defaults (monospace, sans-serif, serif)

---

## Phase 4: Login Management (`modules/login/`)

- [✓] **`default.nix`**: greetd + tuigreet with Steelbore branding
- [✓] **`default.nix`**: Session memory and ISO 8601 time display
- [✓] **`default.nix`**: Shell sessions (Ion, Nushell, Brush) via `mkShellSession`
- [✓] **`default.nix`**: Register session packages (niri, cosmic, ion, nushell, brush)
- [✓] **`default.nix`**: PAM gnome-keyring integration

---

## Phase 5: Desktop Environments (`modules/desktops/`)

### GNOME (`gnome.nix`)

- [✓] Define `steelbore.desktops.gnome` option
- [✓] Enable GNOME on Wayland, disable GDM (use greetd)
- [✓] Install GNOME Tweaks, dconf-editor
- [✓] Install extension manager and browser connector
- [✓] Install curated extensions (14: Caffeine, Just Perfection, Forge, etc.)
- [✓] Configure XDG portals (gnome, gtk)
- [✓] Exclude bloatware (Tour, Music, Epiphany, Geary, Totem)

### COSMIC (`cosmic.nix`)

- [✓] Define `steelbore.desktops.cosmic` option
- [✓] Enable COSMIC DE, disable cosmic-greeter (use greetd)

### KDE Plasma 6 (`plasma.nix`)

- [✓] Define `steelbore.desktops.plasma` option
- [✓] Enable Plasma 6 on Wayland, disable SDDM (use greetd)
- [✓] Enable X server for XWayland support
- [✓] Configure SSH askpass override (`ksshaskpass`)
- [✓] Install KDE packages (8: browser-integration, kdeconnect, systemmonitor, etc.)
- [✓] Enable KWallet and Krohnkite tiling
- [✓] Enable GPG agent with pinentry-qt
- [✓] Exclude bloatware (oxygen, elisa, khelpcenter)

### Niri (`niri.nix`) -- The Steelbore Standard

- [✓] Define `steelbore.desktops.niri` option
- [✓] Enable Niri compositor
- [✓] Install companion packages (14: swaybg, xwayland-satellite, ironbar, waybar, etc.)
- [✓] Write `/etc/niri/config.kdl` with Steelbore palette
- [✓] Write `/etc/ironbar/config.yaml` and `/etc/ironbar/style.css`
- [✓] Configure keybindings (Vim-style + CUA arrows); `Mod+Return` → rio (default terminal)
- [✓] Configure workspaces 1-5
- [✓] Configure startup applications (swaybg, ironbar, wired)
- [✓] Configure input (keyboard `us,ar` with `grp:ctrl_space_toggle`, touchpad)

### LeftWM (`leftwm.nix`)

- [✓] Define `steelbore.desktops.leftwm` option
- [✓] Enable X11 and LeftWM, configure XKB layout (`us,ar`)
- [✓] Install companion packages (15: rlaunch, rofi, dmenu, polybar, picom, etc.)
- [✓] Write `/etc/leftwm/config.ron` with keybindings; `Mod+Return` → rio (default terminal)
- [✓] Write theme files (`theme.ron`, `up`, `down`, `polybar.ini`, `template.liquid`, `picom.conf`)
- [✓] Write `/etc/dunst/dunstrc` with Steelbore theme

---

## Phase 6: Package Modules (`modules/packages/`)

### Infrastructure

- [✓] **`default.nix`**: Package module entry with imports (all 12 submodules)

### browsers.nix

- [✓] Define `steelbore.packages.browsers` option
- [✓] Enable Firefox via `programs.firefox`
- [✓] Install browsers (Chrome, Brave, Edge, Librewolf)

### terminals.nix

- [✓] Define `steelbore.packages.terminals` option
- [✓] Install Rust terminals (Alacritty, WezTerm, Rio, Warp)
- [✓] Install Ghostty (Zig)
- [✓] Install GTK/VTE terminals (Ptyxis, GNOME Console)
- [✓] Install AI-native terminals (WaveTerm)
- [✓] Install KDE terminals (Konsole, Yakuake)
- [✓] Install other terminals (Foot, XTerm, XFCE4 Terminal, Termius, COSMIC Term)
- [✓] Write system-level configs for all 15 terminals with Steelbore theme

### editors.nix

- [✓] Define `steelbore.packages.editors` option
- [✓] Install linting (markdownlint-cli2)
- [✓] Install Rust TUI editors (Helix, Amp, msedit)
- [✓] Install standard TUI editors (Neovim, Vim, mg, mc)
- [✓] Install Rust GUI editors (zed-editor-fhs, Lapce, Neovide, cosmic-edit)
- [✓] Install standard GUI editors (Emacs-pgtk, VSCode-FHS, gedit)

### development.nix

- [✓] Define `steelbore.packages.development` option
- [✓] Install Git and Rust VCS tools (gitui, delta, jujutsu)
- [✓] Install gh and github-desktop
- [✓] Install Forgejo stack (forgejo, forgejo-cli, forgejo-runner)
- [✓] Install Rust toolchain (rustup, cargo, cargo-update)
- [✓] Install build tools (just, sad, pueue, tokei)
- [✓] Install environment tools (lorri, dotter)
- [✓] Install Cloud CLIs (google-cloud-sdk, azure-cli, awscli)
- [✓] Install languages (JDK, PHP)
- [✓] Install Nix ecosystem (nixfmt, cachix, nix, guix)
- [✓] Configure system Git defaults (`init.defaultBranch`, `core.editor`)

### security.nix

- [✓] Define `steelbore.packages.security` option
- [✓] Install Rust encryption (age, rage)
- [✓] Install sops for secrets
- [✓] Install Sequoia PGP stack (sq, chameleon, wot, sqv, sqop)
- [✓] Install password managers (rbw, bitwarden-cli/desktop, authenticator)
- [✓] Install SSH tools (openssh_hpn)
- [✓] Install pika-backup (Rust, Borg frontend)
- [✓] Install sydbox (process sandboxing)
- [✓] Install sbctl (Secure Boot)

### networking.nix

- [✓] Define `steelbore.packages.networking` option
- [✓] Install network management (impala, iwd)
- [✓] Install HTTP clients (xh, monolith, curlFull, wget2)
- [✓] Install Rust diagnostics (gping, trippy, lychee, rustscan, sniffglue, bandwhich)
- [✓] Install GUI tools (sniffnet, mullvad-vpn, rqbit)
- [✓] Install download managers (aria2, uget)
- [✓] Install clipboard tools (wl-clipboard, wl-clipboard-rs)
- [✓] Install DNS & services (dnsmasq, atftp, adguardhome)

### multimedia.nix

- [✓] Define `steelbore.packages.multimedia` option
- [✓] Install video players (mpv, vlc, cosmic-player)
- [✓] Install Rust audio (amberol, termusic, ncspot, psst, shortwave)
- [✓] Install Rust image viewers (loupe, viu, emulsion)
- [✓] Install mousai (audio recognition)
- [✓] Install processing tools (rav1e, gifski, oxipng, video-trimmer, ffmpeg)
- [✓] Install yt-dlp

### productivity.nix

- [✓] Define `steelbore.packages.productivity` option
- [✓] Install Rust knowledge tools (AppFlowy, Affine)
- [✓] Install CLI note-taking (nb)
- [✓] Install office suites (LibreOffice, OnlyOffice)
- [✓] Install utilities (qalculate-gtk)
- [✓] Install communication (Fractal, NewsFlash, Tutanota, Onedriver)

### system.nix

- [✓] Define `steelbore.packages.system` option
- [✓] Install modern Unix (fd, ripgrep, bat, eza, sd, zoxide, procs, dust, dua)
- [✓] Install uutils (coreutils, diffutils, findutils)
- [✓] Install file managers (yazi, broot, superfile, spacedrive, fclones, kondo, pipe-rename, ouch)
- [✓] Install disk tools (gptman, parted, tparted, gparted)
- [✓] Install monitoring (bottom, kmon, macchina, bandwhich, mission-center, htop, btop, gotop, fastfetch, i7z, hw-probe)
- [✓] Install text processing (jaq, teip, htmlq, skim, tealdeer, mdcat, difftastic)
- [✓] Install Rust shells (nushell, brush, ion, starship, atuin, pipr, moor, powershell)
- [✓] Install multiplexers (zellij, screen)
- [✓] Install t-rec (terminal recorder)
- [✓] Install containers (steam-run, distrobox, boxbuddy, host-spawn, podman, runc, youki, oxker, qemu, flatpak, bubblewrap)
- [✓] Install system management (topgrade, paru, doas, os-prober, kbd, numlockx, xremap, input-leap)
- [✓] Install archiving (p7zip, zip, unzip)
- [✓] Install ZFS tools and antigravity-fhs
- [✓] Install benchmarking (phoronix-test-suite, perf)
- [✓] Enable Flatpak and AppImage (binfmt) services
- [✓] Enable Podman with `dockerCompat`, runc + youki runtimes

### ai.nix

- [✓] Define `steelbore.packages.ai` option
- [✓] Install Rust AI tools (aichat, gemini-cli)
- [✓] Install opencode (Go)
- [✓] Install AI tools (codex, copilot-cli, gpt-cli, mcp-nixos)
- [✓] Install task-master-ai
- [✓] Install claude-code from channel-appropriate `pkgs` (stable on stable, unstable on unstable)

### flatpak.nix

- [✓] Define `steelbore.packages.flatpak` option
- [✓] Configure Flathub remote
- [✓] Declare Flatpak packages (42+ apps across terminals, browsers, communication, security, development, gaming, retro, productivity, incl. org.gnome.baobab disk usage analyzer)

---

## Phase 7: Hardware Modules (`modules/hardware/`)

- [✓] **`default.nix`**: Hardware module entry point (imports fingerprint, intel)
- [✓] **`fingerprint.nix`**: Define option, enable fprintd
- [✓] **`intel.nix`**: Define option with `marchLevel` suboption (enum: v1/v2/v3/v4, default: v4)
- [✓] **`intel.nix`**: Enable `kvm-intel` module, Intel microcode updates
- [✓] **`intel.nix`**: Set per-level optimization flags (CFLAGS, CXXFLAGS, RUSTFLAGS, GOAMD64, LDFLAGS, LTOFLAGS)
- [✓] **`intel.nix`**: v1/v3/v4 CachyOS-sourced flags, v2 ALHP-sourced flags

---

## Phase 8: Host & User Configuration

### Host (`hosts/lattice/`)

- [✓] **`default.nix`**: Set hostname to `lattice`
- [✓] **`default.nix`**: Enable NetworkManager
- [✓] **`default.nix`**: Configure X11 keyboard layout (`us,ara`, `grp:ctrl_space_toggle`)
- [✓] **`default.nix`**: Console keymap `us`
- [✓] **`default.nix`**: Enable printing
- [✓] **`default.nix`**: Create user `mj` with groups (networkmanager, wheel, input, video, audio)
- [✓] **`default.nix`**: Set user shell to Nushell (Rust), root shell to Brush (Rust)
- [✓] **`default.nix`**: Register Nushell, Brush, Ion as valid login shells; bash excluded from `environment.shells` (`programs.bash.enable` kept — NixOS PAM/activation scripts require it; overlay replacement impossible due to nixpkgs bootstrapping cycle)
- [✓] **`default.nix`**: Enable all steelbore desktop modules (gnome, cosmic, plasma, niri, leftwm)
- [✓] **`default.nix`**: Enable all steelbore hardware modules (fingerprint, intel)
- [✓] **`default.nix`**: Enable all steelbore package modules (12 modules including flatpak)
- [✓] **`default.nix`**: Set `stateVersion = "25.11"`
- [✓] **`hardware.nix`**: Import from `modulesPath`, configure root (ext4) and boot (vfat) filesystems

### User (`users/mj/`)

- [✓] **`default.nix`**: Define user account
- [✓] **`home.nix`**: Set username, home directory, stateVersion 25.11
- [✓] **`home.nix`**: Create `~/steelbore` symlink to `/steelbore`
- [✓] **`home.nix`**: Configure keyboard layout (`us,ara`, `grp:ctrl_space_toggle`)
- [✓] **`home.nix`**: Set session variables (`EDITOR`, `VISUAL` to msedit, `STEELBORE_THEME`)
- [✓] **`home.nix`**: Configure Git with SSH signing (Sequoia), LFS enabled
- [✓] **`home.nix`**: Configure Starship prompt (Tokyo Night preset)
- [✓] **`home.nix`**: Configure Nushell with aliases (telemetry, steelbore banner)
- [✓] **`home.nix`**: Configure Ion shell init (`~/.config/ion/initrc`) with aliases
- [✓] **`home.nix`**: Configure Alacritty with Steelbore colors (via `programs.alacritty`)
- [✓] **`home.nix`**: Write user-level XDG configs (niri, ironbar, wezterm, rio, ghostty, foot, xfce4-terminal, konsole, yakuake, xresources)
- [✓] **`home.nix`**: Configure dconf settings (Ptyxis profile, GNOME Console)
- [✓] **`home.nix`**: Configure containers (`~/.config/containers/containers.conf`, runc default)

---

## Phase 9: Overlays (`overlays/default.nix`)

- [✓] **sequoia-wot**: Disable failing tests (`doCheck = false`)
- [✓] **claude-code**: Pinned to 2.1.113 via `overrideAttrs` overlay; `src` built with `runCommand` to bake `overlays/claude-code-package-lock.json` into the source tree; `npmDeps` explicitly overridden (workaround for `overrideAttrs` not propagating into internal `fetchNpmDeps`); `postInstall` copies native binary from `@anthropic-ai/claude-code-linux-x64` over the placeholder `bin/claude.exe`; `autoPatchelfHook` + `autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ]` for ELF patching on NixOS
- [✓] **overlay location**: Defined inline in `modules/core/nix.nix`; reference copy in `overlays/default.nix`
- [✓] **bash→brush overlay**: Investigated and found infeasible — nixpkgs bootstrapping cycle prevents overriding `pkgs.bash` via any overlay

---

## Phase 10: Testing & Verification

- [✓] Run `nix flake check` without errors
- [✓] Run `nix flake show` and verify 10 configurations listed
- [✓] Run `nixos-rebuild dry-build --flake .#lattice` successfully
- [✓] Run `nixos-rebuild build --flake .#lattice` successfully
- [✓] Run `nixos-rebuild switch --flake .#lattice` successfully
- [✓] Verify march-level variant build (`nixos-rebuild build --flake .#lattice-v3`)
- [✓] Verify unstable channel build (`nixos-rebuild build --flake .#lattice-unstable`)
- [~] Verify Niri session boots with Ironbar
- [✓] Verify COSMIC session boots with panel
- [✓] Verify GNOME session boots on Wayland
- [✓] Verify KDE Plasma 6 session boots on Wayland
- [ ] Verify LeftWM session boots with Polybar
- [✓] Verify greetd/tuigreet login with session selection
- [✓] Verify Steelbore palette on TTY
- [~] Verify Steelbore palette on all themed terminals (15)
- [ ] Verify Steelbore palette on Ironbar and Polybar
- [ ] Verify sudo-rs works for privilege escalation
- [✓] Verify fingerprint authentication (fprintd)
- [ ] Verify Podman with `docker` compat alias
- [✓] Verify Flatpak apps install from Flathub
- [ ] Verify AppImage binfmt execution

---

## Phase 11: Documentation

- [✓] **README.md**: Project overview and quick start
- [✓] **ARCHITECTURE.md**: System diagrams and data flow
- [✓] **TODO.md**: Implementation checklist (this file)
- [✓] **PRD.md**: Product requirements (v3.0)

---

## Known Issues & Notes

1. **COSMIC packages**: Uses native nixpkgs module (no third-party flake). `useFetchCargoVendor` deprecation warnings come from upstream nixpkgs packages — harmless.

2. **claude-code**: Pinned to 2.1.113 via `overrideAttrs` overlay in `modules/core/nix.nix`. Lock file stored at `overlays/claude-code-package-lock.json`. Native-binary architecture (since ~2.1.113) requires explicit `npmDeps` override, `postInstall` copy from `@anthropic-ai/claude-code-linux-x64`, and `autoPatchelfHook`. See `CLAUDE.md` constraint #4 for full gotchas and update procedure.

3. **XanMod kernel**: Sourced from unstable channel for latest version.

4. **sequoia-wot**: Tests disabled via overlay due to build failures.

5. **Console keymap**: Set to `us` only -- ckbcomp can't resolve multi-layout XKB configs (`us,ara`).

6. **Bash cannot be replaced via nixpkgs overlay**: Every nixpkgs derivation uses `final.bash` as its build shell via stdenv. Overriding `pkgs.bash` in an overlay creates an unavoidable bootstrapping cycle (`final.bash → prev.bash.stdenv.shell = "${final.bash}/bin/bash" → final.bash`). Bash is excluded from login shells but `programs.bash.enable` must remain `true` for NixOS PAM and activation script generation. Users get Nushell; root gets Brush.

7. **Overlays** are defined inline in `modules/core/nix.nix`. `overlays/default.nix` exists as a reference copy.

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

*Last updated: 2026-04-20*
