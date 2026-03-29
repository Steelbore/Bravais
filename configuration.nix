# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
    boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.desktopManager.gnome.enable= true;
  services.displayManager.gdm.enable = true;

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
    extraGroups = [ "networkmanager" "wheel" "input" "docker" "mj" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pkgs.linuxKernel.kernels.linux_xanmod_latest
    # 🌐 Browsers
    google-chrome
    brave
    microsoft-edge
    librewolf

    # 🖥️ GUI / Editors / Terminals
    zed-editor
    lapce
    alacritty
    wezterm
    ptyxis
    waveterm
    warp-terminal
    termius
    vscode
    vscodium
    emacs-pgtk
    gedit
    dconf-editor
    github-desktop
    libreoffice-fresh
    onlyoffice-desktopeditors
    qalculate-gtk
    vlc
    tutanota-desktop
    bitwarden-desktop
    onedriver
    superfile

    # 📝 Productivity & Notes
    appflowy
    affine

    # 🎮 Gaming / Emulation
    dosbox
    dosbox-x
    #emu2
    #retroarch-full

    # 🔐 Security & Passwords
    bitwarden-cli
    gnupg
    gpg-tui
    age
    sops
    pinentry-gnome3
    pinentry-curses

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

    # 🐚 Shells & Prompt
    nushell
    ion
    starship
    pipr
    sudo-rs
    moar
    powershell

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
    codex
    copilot-cli
    github-copilot-cli
    opencode
    aichat
    gemini-cli
    claude-code
    gpt-cli
    emacsPackages.claude-code

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
    gh
    cachix
    guix
    emacsPackages.guix

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
    antigravity
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

}
