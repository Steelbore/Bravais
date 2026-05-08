# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

let
  # Import the unstable channel you just added
  unstable = import <nixos-unstable> {
    config = config.nixpkgs.config; # Inherit system config (like allowUnfree)
  };
in
{
  imports = [
    ./hosts/lattice/hardware-configuration.nix
    "${builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz"}/nixos"
  ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    unstable.linuxKernel.kernels.linux_xanmod_latest
    unstable.mcp-nixos

    # 🌐 Browsers
    unstable.google-chrome
    unstable.brave
    unstable.microsoft-edge
    unstable.librewolf
    pinokio

    # 🖥️ GUI / Editors / Terminals
    unstable.zed-editor
    lapce
    unstable.alacritty
    unstable.wezterm
    unstable.ptyxis
    unstable.waveterm
    unstable.warp-terminal
    termius
    unstable.vscode
    unstable.vscodium
    unstable.code-cursor
    emacs-pgtk
    gedit
    dconf-editor
    github-desktop
    libreoffice-fresh
    onlyoffice-desktopeditors
    qalculate-gtk
    vlc
    unstable.tutanota-desktop
    unstable.bitwarden-desktop
    onedriver
    superfile
    pkgs.rio

    # 📝 Productivity & Notes
    appflowy
    affine

    # 🎮 Gaming / Emulation
    dosbox
    dosbox-x
    #emu2
    #retroarch-full

    # 🔐 Security & Passwords
    unstable.bitwarden-cli
    openssh
    #gnupg
    #gpg-tui
    fprintd
    gnome-keyring

    # File encryption & Secrets
    #age
    rage
    sops
    # PGP Ecosystem
    pkgs.sequoia-sq
    pkgs.sequoia-chameleon-gnupg
    #pinentry-gnome3
    #pinentry-curses
    pkgs.sequoia-wot
    pkgs.sequoia-sqv
    pkgs.sequoia-sqop

    # 📦 Archive & File Tools
    p7zip
    zip
    unzip
    #ventoy-full

    # 📥 Download & Transfer
    aria2
    uget
    yt-dlp
    rqbit
    curlFull
    wget
    wget2
    monolith

    # 🐳 Containers & Virtualization
    distrobox
    boxbuddy
    qemu
    flatpak
    bubblewrap

    # 🐚 Shells & Prompt
    nushell
    ion
    starship
    pipr
    sudo-rs
    unstable.moor
    unstable.powershell

    # 📂 Navigation
    zoxide
    broot
    yazi

    # 📜 Text & Search
    bat
    mdcat
    ripgrep
    skim
    sd
    delta
    tealdeer
    difftastic
    #  frawk

    # 📊 System Monitors
    bottom
    #  ytop
    procs
    macchina
    htop
    htop-vim
    gotop
    btop
    i7z
    fastfetch
    hw-probe
    kmon
    bandwhich
    mission-center

    # 📦 File & Disk
    dust
    dua
    ouch
    fclones
    teip
    htmlq
    viu
    emulsion
    t-rec

    # 🤖 AI Coding Tools
    unstable.codex
    unstable.github-copilot-cli
    unstable.opencode
    unstable.aichat
    unstable.gemini-cli
    unstable.gpt-cli
    unstable.cursor-cli
    claude-code

    # 🔧 Dev Tools
    just
    tokei
    sad
    pueue
    gitui
    pipe-rename
    amp
    topgrade
    cargo
    rustup
    dotter
    jdk
    php
    git
    unstable.gh
    cachix
    guix
    emacsPackages.guix
    nixfmt

    # 🌐 Networking
    fd
    paru
    matrix-commander-rs
    wl-clipboard-rs
    openssh_hpn
    dnsmasq
    atftp
    adguardhome

    # 🖊️ Terminal Editors
    vim
    neovim
    mg
    vimacs
    mc
    msedit

    # 🐧 System Utilities
    uutils-coreutils
    uutils-diffutils
    uutils-findutils
    zfs
    unstable.antigravity
    doas
    eza
    screen
    os-prober
    kbd
    numlockx
    xremap
    glibc
    phoronix-test-suite
    perf
    input-leap

    # 🪐 COSMIC / Extra Desktop
    cosmic-bg
    cosmic-osd
    cosmic-term
    cosmic-idle
    cosmic-edit
    cosmic-comp
    cosmic-store
    cosmic-randr
    cosmic-panel
    cosmic-icons
    cosmic-files
    cosmic-reader
    cosmic-player
    cosmic-session
    cosmic-greeter
    cosmic-ext-ctl
    cosmic-applets
    cosmic-settings
    cosmic-launcher
    cosmic-protocols
    cosmic-wallpapers
    cosmic-screenshot
    cosmic-ext-tweaks
    cosmic-applibrary
    cosmic-design-demo
    cosmic-notifications
    cosmic-initial-setup
    cosmic-ext-calculator
    cosmic-settings-daemon
    cosmic-workspaces-epoch
    cosmic-ext-applet-minimon
    cosmic-ext-applet-caffeine
    cosmic-ext-applet-privacy-indicator
    cosmic-ext-applet-external-monitor-brightness
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xdg-desktop-portal-cosmic

    # 🖥️ Display Managers / Greeters
    greetd
    tuigreet
    lemurs

    # 🪟 Window Managers & Bars
    niri
    leftwm
    leftwm-theme
    leftwm-config
    ironbar
    eww

    # 🚀 Launchers
    anyrun
    rlaunch
    onagre

    # 🔔 Notification Daemons
    wired

    # 🧩 GNOME Extensions & Tools
    gnome-extension-manager
    gnome-browser-connector
    gnomeExtensions.caffeine
    gnomeExtensions.just-perfection
    gnomeExtensions.window-gestures
    gnomeExtensions.wayland-or-x11
    gnomeExtensions.toggler
    gnomeExtensions.vim-alt-tab
    gnomeExtensions.yakuake
    gnomeExtensions.open-bar
    gnomeExtensions.tweaks-in-system-menu
    gnomeExtensions.launcher
    gnomeExtensions.window-title-is-back
  ];

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      sequoia-wot = prev.sequoia-wot.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = unstable.linuxPackages_xanmod_latest;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "lattice"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Bahrain";

  # Select internationalisation properties.
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

  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root -"
    "d /var/tmp 1777 root root -"
  ];

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  services.fprintd.enable = true;
  #services.fprintd.tod.enable = true;
  #services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;
  # If the above doesn't work, try this one:
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable greetd
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd cosmic-session";
        user = "mj";
      };
    };
  };

  services.desktopManager.gnome.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = false;

  services.xserver.windowManager.leftwm.enable = true;
  programs.niri.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.mj = {
    isNormalUser = true;
    description = "Mohamed Hammad";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "docker"
      "mj"
    ];
  };

  environment.sessionVariables = {
    # Rust (Cargo) flags
    RUSTFLAGS = "-C target-cpu=x86-64-v4 -C opt-level=3";

    # Go flags
    GOAMD64 = "v4";

    # Optional C/C++ flags for local Make/CMake builds outside of Nix builds
    CFLAGS = "-march=x86-64-v4 -O3 -pipe -fno-plt -flto=auto";
    CXXFLAGS = "-march=x86-64-v4 -O3 -pipe -fno-plt -flto=auto";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  # Home Manager Configuration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.mj =
    { config, lib, ... }:
    {
      imports = [ ./hosts/lattice/home.nix ];
      home.file."steelbore".source = config.lib.file.mkOutOfStoreSymlink "/steelbore";
    };

}
