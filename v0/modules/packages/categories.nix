{ pkgs, unstable, emacs-ng, gws-cli, ... }:

{
  environment.systemPackages = [
    # ══════════════════════════════════════════════════════════════════
    # 1. Boot & Login
    # ══════════════════════════════════════════════════════════════════
    # Bootloader: Lanzaboote → imported as flake module in flake.nix
    pkgs.sbctl                         #🦀 [CLI] Secure Boot Manager

    # Login Managers
    pkgs.greetd                        #🦀 [Daemon]
    pkgs.tuigreet                      #🦀 [TUI] Best for Niri/LeftWM
    pkgs.lemurs                        #🦀 [TUI]
    # cosmic-greeter                   # → cosmic.nix (service toggle)

    # System Components
    # xdg-desktop-portal-cosmic        # → cosmic.nix
    # sudo-rs                          # → settings.nix (security.sudo-rs)

    # ══════════════════════════════════════════════════════════════════
    # 2. Browsers
    # ══════════════════════════════════════════════════════════════════
    # Firefox → enabled via programs.firefox.enable in default.nix
    unstable.google-chrome             #⚠️  [GUI] (C++)
    unstable.brave                     #⚠️  [GUI] (C++)
    unstable.microsoft-edge            #⚠️  [GUI] (C++)
    unstable.librewolf                 #⚠️  [GUI] (C++)

    # ══════════════════════════════════════════════════════════════════
    # 3. Desktop & Window Management
    # ══════════════════════════════════════════════════════════════════
    # Window Managers & Sessions
    # niri                             # → niri.nix
    # leftwm                           # → leftwm.nix
    # COSMIC DE                        # → cosmic.nix
    # cosmic-session                   # → cosmic.nix

    # Launchers
    # anyrun                           # → niri.nix
    # rlaunch                          # → leftwm.nix
    pkgs.onagre                        #🦀 [GUI]

    # Input Tools
    pkgs.xremap                        #🦀 [CLI] Dynamic key remapper

    # Desktop Utilities
    pkgs.dconf-editor                  #⚠️  [GUI] GSettings editor
    pkgs.github-desktop                #⚠️  [GUI] Git GUI
    pkgs.xdg-desktop-portal-gtk        #⚠️  [Daemon] GTK portal
    pkgs.xdg-desktop-portal-gnome      #⚠️  [Daemon] GNOME portal

    # ══════════════════════════════════════════════════════════════════
    # 4. GNOME Extensions
    # ══════════════════════════════════════════════════════════════════
    pkgs.gnome-extension-manager       #⚠️  [GUI] Extension manager
    pkgs.gnome-browser-connector       #⚠️  [CLI] Browser integration
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.just-perfection
    pkgs.gnomeExtensions.window-gestures
    pkgs.gnomeExtensions.wayland-or-x11
    pkgs.gnomeExtensions.toggler
    pkgs.gnomeExtensions.vim-alt-tab
    pkgs.gnomeExtensions.yakuake
    pkgs.gnomeExtensions.open-bar
    pkgs.gnomeExtensions.tweaks-in-system-menu
    pkgs.gnomeExtensions.launcher
    pkgs.gnomeExtensions.window-title-is-back

    # ══════════════════════════════════════════════════════════════════
    # 5. System Monitoring & Panels
    # ══════════════════════════════════════════════════════════════════
    # Bars & Widgets
    pkgs.ironbar                       #🦀 [GUI] The "Steelbore" Bar
    pkgs.eww                           #🦀 [GUI] Custom Widgets

    # Notifications
    pkgs.wired                         #🦀 [Daemon] Notification daemon

    # Hardware & Kernel
    pkgs.kmon                          #🦀 [TUI] Kernel manager
    pkgs.bottom                        #🦀 [TUI] Process monitor
    pkgs.bandwhich                     #🦀 [TUI] Bandwidth usage
    pkgs.mission-center                #🦀 [GUI] Task Manager
    pkgs.macchina                      #🦀 [CLI] System fetch
    pkgs.htop                          #⚠️  [TUI] (C) Process viewer
    pkgs.btop                          #⚠️  [TUI] (C++) Resource monitor
    pkgs.gotop                         #🐹 [TUI] (Go) System monitor
    pkgs.i7z                           #⚠️  [CLI] (C) Intel CPU reporting
    pkgs.fastfetch                     #⚠️  [CLI] (C) System info
    pkgs.hw-probe                      #⚠️  [CLI] Hardware probe

    # ══════════════════════════════════════════════════════════════════
    # 6. Package & System Management
    # ══════════════════════════════════════════════════════════════════
    # The Rust Stack
    pkgs.topgrade                      #🦀 [CLI] Updates everything at once
    pkgs.paru                          #🦀 [CLI] Fast AUR Helper
    pkgs.cargo-update                  #🦀 [CLI] Updates Cargo binaries
    # pkgs.omni                        # NOT IN NIXPKGS — Universal Package Manager
    # pkgs.zap                         # NOT IN NIXPKGS — AppImage/System Tool
    # pkgs.linutil                     # NOT IN NIXPKGS — Distro maintenance tool

    # Dotfile Management
    pkgs.dotter                        #🦀 [CLI] Dotfile manager and templater

    # The Standard Stack
    pkgs.guix                          #(λ) [CLI] Guile Scheme
    pkgs.flatpak                       #⚠️  [CLI] (C)
    pkgs.nix                           #⚠️  [CLI] (C++)
    pkgs.cachix                        #⚠️  [CLI] Binary cache
    pkgs.nixfmt                        #🦀 [CLI] Nix formatter

    # ══════════════════════════════════════════════════════════════════
    # 7. File & Disk Management
    # ══════════════════════════════════════════════════════════════════
    # File Managers
    pkgs.yazi                          #🦀 [TUI]
    pkgs.broot                         #🦀 [TUI]
    unstable.superfile                 #🐹 [TUI] (Go)
    # cosmic-files                     # → cosmic.nix
    unstable.spacedrive                #🦀 [GUI]

    # Disk Usage & Cleaning
    pkgs.dust                          #🦀 [CLI] Disk usage analyzer
    pkgs.dua                           #🦀 [TUI] Interactive disk usage
    pkgs.fclones                       #🦀 [CLI] Duplicate finder
    pkgs.kondo                         #🦀 [CLI] Project cleaner

    # Partitioning
    unstable.disktui                   #🦀 [TUI] Interactive Partition Manager
    pkgs.gptman                        #🦀 [CLI] Scriptable GPT Manager

    # Archive & Compression
    pkgs.ouch                          #🦀 [CLI] Painless compression
    pkgs.p7zip                         #⚠️  [CLI] (C++) 7-Zip
    pkgs.zip                           #⚠️  [CLI] (C) Zip archiver
    pkgs.unzip                         #⚠️  [CLI] (C) Zip extractor

    # Text Processing
    pkgs.teip                          #🦀 [CLI] Masking tool for pipes
    pkgs.htmlq                         #🦀 [CLI] HTML selector (like jq)

    # ══════════════════════════════════════════════════════════════════
    # 8. Core Utilities (The "Modern Unix" Stack)
    # ══════════════════════════════════════════════════════════════════
    # File Operations
    pkgs.fd                            #🦀 [CLI] User-friendly find
    pkgs.ripgrep                       #🦀 [CLI] Fast grep
    pkgs.bat                           #🦀 [CLI] cat with syntax highlighting
    pkgs.eza                           #🦀 [CLI] Modern ls
    pkgs.sd                            #🦀 [CLI] Intuitive sed
    pkgs.zoxide                        #🦀 [CLI] Smarter cd
    pkgs.pipe-rename                   #🦀 [CLI] Rename files interactively

    # Text Processing
    pkgs.jaq                           #🦀 [CLI] JSON processor (jq clone)
    pkgs.uutils-coreutils              #🦀 [CLI] Coreutils reimplementation
    pkgs.uutils-diffutils              #🦀 [CLI] Diffutils reimplementation
    pkgs.uutils-findutils              #🦀 [CLI] Findutils reimplementation
    pkgs.procs                         #🦀 [CLI] Modern ps
    pkgs.tokei                         #🦀 [CLI] Code statistics tool

    # Search & Reference
    pkgs.skim                          #🦀 [CLI] Fuzzy finder
    pkgs.tealdeer                      #🦀 [CLI] Simplified man pages (tldr)
    pkgs.mdcat                         #🦀 [CLI] Markdown renderer for terminal
    pkgs.difftastic                    #🦀 [CLI] Structural diff tool

    # ══════════════════════════════════════════════════════════════════
    # 9. Development & Git
    # ══════════════════════════════════════════════════════════════════
    # Git & Ops
    pkgs.gitui                         #🦀 [TUI] Blazing fast Git UI
    pkgs.delta                         #🦀 [CLI] Syntax-highlighting pager
    pkgs.jujutsu                       #🦀 [CLI] Git-compatible DVCS (jj)
    unstable.gh                        #🐹 [CLI] (Go) GitHub CLI

    # Toolchains & Env
    pkgs.rustup                        #🦀 [CLI] Rust toolchain
    pkgs.cargo                         #🦀 [CLI] Rust package manager
    pkgs.lorri                         #🦀 [CLI] Nix environment manager daemon
    pkgs.just                          #🦀 [CLI] Command runner

    # Build & Task Tools
    pkgs.sad                           #🦀 [CLI] Batch search & replace
    pkgs.pueue                         #🦀 [CLI] Task management daemon

    # Languages
    pkgs.jdk                           #⚠️  [CLI] Java Development Kit
    pkgs.php                           #⚠️  [CLI] PHP interpreter

    # Nix Ecosystem
    pkgs.emacsPackages.guix            #(λ) [Emacs] Guix integration

    # ══════════════════════════════════════════════════════════════════
    # 10. Security & Encryption
    # ══════════════════════════════════════════════════════════════════
    # Encryption Tools
    pkgs.age                           #🦀 [CLI] Modern encryption (age)
    pkgs.rage                          #🦀 [CLI] Modern encryption (rage)
    pkgs.sops                          #🐹 [CLI] (Go) Secret management

    # PGP / Sequoia Stack
    pkgs.sequoia-chameleon-gnupg       #🦀 [CLI] GnuPG drop-in replacement
    pkgs.sequoia-sq                    #🦀 [CLI] Sequoia CLI
    pkgs.sequoia-wot                   #🦀 [CLI] Web of Trust
    pkgs.sequoia-sqv                   #🦀 [CLI] Signature verifier
    pkgs.sequoia-sqop                  #🦀 [CLI] Stateless OpenPGP

    # Password & Auth
    pkgs.rbw                           #🦀 [CLI] Bitwarden Client
    unstable.bitwarden-cli             #⚠️  [CLI] (TS) Bitwarden CLI
    unstable.bitwarden-desktop         #⚠️  [GUI] (TS) Bitwarden Desktop
    # goldwarden                       # Upstream flake removed — use bitwarden-desktop instead
    pkgs.authenticator                 #🦀 [GUI] 2FA/OTP Client

    # SSH
    pkgs.openssh                       #⚠️  [CLI] (C) SSH client/server
    pkgs.openssh_hpn                   #⚠️  [CLI] (C) High Performance SSH

    # Backup & App Stores
    unstable.pika-backup               #🦀 [GUI] Borg Frontend
    # cosmic-store                     # → cosmic.nix

    # ══════════════════════════════════════════════════════════════════
    # 11. Networking & Internet
    # ══════════════════════════════════════════════════════════════════
    # Network Management
    pkgs.impala                        #🦀 [TUI] TUI for iwd
    pkgs.iwd                           #⚠️  [CLI] Modern Wi-Fi daemon (C)
    # pkgs.nmstate                     # Not in nixpkgs 25.11

    # Diagnostics & Tools
    pkgs.xh                            #🦀 [CLI] curl replacement
    pkgs.monolith                      #🦀 [CLI] wget archiver
    pkgs.lychee                        #🦀 [CLI] Link checker
    pkgs.gping                         #🦀 [CLI] Graphical ping
    pkgs.rustscan                      #🦀 [CLI]
    pkgs.sniffglue                     #🦀 [CLI]
    pkgs.trippy                        #🦀 [TUI]

    # Standard Stack
    pkgs.wget2                         #⚠️  [CLI] (C)
    pkgs.curlFull                      #⚠️  [CLI] (C) curl with all features
    pkgs.wl-clipboard-rs              #🦀 [CLI] Wayland clipboard

    # DNS & Services
    pkgs.dnsmasq                       #⚠️  [Daemon] (C) DNS/DHCP
    pkgs.atftp                         #⚠️  [CLI] (C) TFTP client/server
    pkgs.adguardhome                   #🐹 [Daemon] (Go) DNS ad blocker

    # Download Tools
    pkgs.aria2                         #⚠️  [CLI] (C++) Multi-protocol downloader
    pkgs.uget                          #⚠️  [GUI] (C) Download manager

    # GUI Apps
    unstable.sniffnet                  #🦀 [GUI]
    pkgs.mullvad-vpn                   #🦀 [GUI]
    unstable.rqbit                     #🦀 [GUI] BitTorrent

    # ══════════════════════════════════════════════════════════════════
    # 12. Terminal Environment
    # ══════════════════════════════════════════════════════════════════
    # Emulators
    pkgs.ghostty                       #⚡  [GUI] Zig — High-performance, native
    pkgs.alacritty                     #🦀 [GUI]
    pkgs.wezterm                       #🦀 [GUI]
    pkgs.rio                           #🦀 [GUI]
    unstable.ptyxis                    #⚠️  [GUI] (C) GNOME terminal
    unstable.waveterm                  #⚠️  [GUI] (TS) AI-native terminal
    unstable.warp-terminal             #⚠️  [GUI] AI-powered terminal
    pkgs.termius                       #⚠️  [GUI] SSH client
    # cosmic-term                      # → cosmic.nix

    # Shells
    pkgs.nushell                       #🦀 [CLI]
    pkgs.brush                         #🦀 [CLI] Bash-Compatible
    pkgs.starship                      #🦀 [CLI]
    pkgs.atuin                         #🦀 [CLI]
    pkgs.ion                           #🦀 [CLI]
    pkgs.pipr                          #🦀 [CLI] Interactive pipeline builder
    unstable.moor                      #🦀 [CLI]
    unstable.powershell                #⚠️  [CLI] (.NET) PowerShell

    # Tools
    pkgs.zellij                        #🦀 [TUI] Multiplexer
    pkgs.t-rec                         #🦀 [CLI] Terminal recorder
    pkgs.screen                        #⚠️  [CLI] (C) Terminal multiplexer

    # ══════════════════════════════════════════════════════════════════
    # 13. Communication
    # ══════════════════════════════════════════════════════════════════
    # Matrix
    pkgs.iamb                          #🦀 [TUI]
    pkgs.fractal                       #🦀 [GUI]

    # Discord
    # rivetui                           # Upstream repo removed (404)

    # Fediverse / Social
    pkgs.newsflash                     #🦀 [GUI] RSS

    # Email
    unstable.tutanota-desktop          #⚠️  [GUI] (TS) Encrypted email

    # Cloud Storage
    pkgs.onedriver                     #🐹 [CLI] (Go) OneDrive client

    # ══════════════════════════════════════════════════════════════════
    # 14. Text Editing
    # ══════════════════════════════════════════════════════════════════
    # CLI/TUI
    pkgs.helix                         #🦀 [TUI]
    pkgs.amp                           #🦀 [TUI]
    pkgs.msedit                        #🦀 [TUI]
    pkgs.neovim                        #⚠️  [TUI] (C) Vim fork
    pkgs.vim                           #⚠️  [TUI] (C)
    pkgs.mg                            #⚠️  [TUI] (C) Micro Emacs
    pkgs.vimacs                        #⚠️  [TUI] Vim with Emacs bindings
    pkgs.mc                            #⚠️  [TUI] (C) Midnight Commander

    # GUI
    pkgs.zed-editor                    #🦀 [GUI]
    pkgs.lapce                         #🦀 [GUI]
    pkgs.neovide                       #🦀 [GUI] Neovim Frontend
    emacs-ng.packages.${pkgs.stdenv.hostPlatform.system}.default #⚠️ [GUI] (C/Lisp/Rust)
    pkgs.emacs-pgtk                    #⚠️  [GUI] (C/Lisp) Emacs with pgtk
    unstable.vscode                    #⚠️  [GUI] (TS) VS Code
    pkgs.vscodium                      #⚠️  [GUI] Telemetry-free VS Code
    # pkgs.code-oss                    # Not in nixpkgs 25.11
    pkgs.gedit                         #⚠️  [GUI] (C) GNOME text editor
    # cosmic-edit                      # → cosmic.nix

    # ══════════════════════════════════════════════════════════════════
    # 15. Multimedia & Processing
    # ══════════════════════════════════════════════════════════════════
    # Video/Audio Players
    pkgs.mpv                           #⚠️  [TUI] (C)
    pkgs.vlc                           #⚠️  [GUI] (C++) Media player
    pkgs.amberol                       #🦀 [GUI] Local Music
    pkgs.shortwave                     #🦀 [GUI] Radio
    pkgs.ncspot                        #🦀 [TUI] Spotify
    pkgs.psst                          #🦀 [GUI] Spotify
    pkgs.termusic                      #🦀 [TUI] Local Music
    pkgs.loupe                         #🦀 [GUI] Image Viewer
    pkgs.viu                           #🦀 [CLI] CLI Image Viewer
    pkgs.emulsion                      #🦀 [GUI] Image Viewer
    pkgs.mousai                        #🦀 [GUI] Song ID

    # Processing & Encoders
    pkgs.ffmpeg                        #⚠️  [CLI] (C)
    pkgs.rav1e                         #🦀 [CLI] AV1 Encoder
    pkgs.gifski                        #🦀 [CLI] GIF Encoder
    pkgs.oxipng                        #🦀 [CLI] PNG Optimizer
    pkgs.gyroflow                      #🦀 [GUI] Stabilization
    pkgs.video-trimmer                 #🦀 [GUI]

    # Downloaders
    pkgs.yt-dlp                        #🐍 [CLI]

    # ══════════════════════════════════════════════════════════════════
    # 16. AI & Productivity
    # ══════════════════════════════════════════════════════════════════
    # AI Coding Agents
    pkgs.opencode                      #🐹 [CLI] Go — Open source coding agent
    unstable.codex                     #⚠️  [CLI] OpenAI Codex
    unstable.github-copilot-cli        #⚠️  [CLI] GitHub Copilot
    unstable.gpt-cli                   #⚠️  [CLI] GPT CLI
    unstable.mcp-nixos                 #⚠️  [CLI] MCP NixOS integration

    # Google Workspace
    gws-cli.packages.${pkgs.stdenv.hostPlatform.system}.default #🦀 [CLI] Google Workspace CLI

    # CLI AI Assistants
    pkgs.aichat                        #🦀 [CLI] Universal Chat REPL
    pkgs.gemini-cli                    #🦀 [CLI]

    # Knowledge & Workflow
    pkgs.appflowy                      #🦀 [GUI] Open Source Notion
    pkgs.affine                        #🦀 [GUI] Knowledge Base & Whiteboard

    # Office
    pkgs.libreoffice-fresh             #⚠️  [GUI] (C++) Office suite
    pkgs.onlyoffice-desktopeditors     #⚠️  [GUI] (C++) Office editors
    pkgs.qalculate-gtk                 #⚠️  [GUI] (C++) Calculator

    # ══════════════════════════════════════════════════════════════════
    # 17. Containers & Virtualization
    # ══════════════════════════════════════════════════════════════════
    pkgs.distrobox                     #⚠️  [CLI] Container manager
    pkgs.boxbuddy                      #🦀 [GUI] Distrobox frontend
    pkgs.qemu                          #⚠️  [CLI] (C) Machine emulator
    pkgs.bubblewrap                    #⚠️  [CLI] (C) Unprivileged sandboxing

    # ══════════════════════════════════════════════════════════════════
    # 18. Gaming & Emulation
    # ══════════════════════════════════════════════════════════════════
    pkgs.dosbox                        #⚠️  [CLI] (C++) DOS emulator
    pkgs.dosbox-x                      #⚠️  [CLI] (C++) DOS emulator (extended)

    # ══════════════════════════════════════════════════════════════════
    # 19. System Infrastructure
    # ══════════════════════════════════════════════════════════════════
    pkgs.zfs                           #⚠️  [CLI] (C) ZFS filesystem
    unstable.antigravity               #🦀 [CLI]
    pkgs.doas                          #⚠️  [CLI] (C) Minimal sudo alternative
    pkgs.os-prober                     #⚠️  [CLI] OS detection
    pkgs.kbd                           #⚠️  [CLI] (C) Keyboard utilities
    pkgs.numlockx                      #⚠️  [CLI] (C) NumLock control
    pkgs.glibc                         #⚠️  [LIB] (C) GNU C Library
    pkgs.phoronix-test-suite           #⚠️  [CLI] (PHP) Benchmarking
    pkgs.perf                          #⚠️  [CLI] (C) Linux performance tools
    pkgs.input-leap                    #⚠️  [GUI] (C++) KVM software
  ];
}
