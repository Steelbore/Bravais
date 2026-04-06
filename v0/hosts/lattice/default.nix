{ config, pkgs, lib, unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel (Xanmod Latest from unstable)
  boot.kernelPackages = unstable.linuxPackages_xanmod_latest;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Hostname & Networking
  networking.hostName = "lattice";
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Asia/Bahrain";

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

  # X11
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Sound (PipeWire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fingerprint reader
  services.fprintd.enable = true;

  # User account
  users.users.mj = {
    isNormalUser = true;
    description = "Mohamed Hammad";
    extraGroups = [ "networkmanager" "wheel" "input" "docker" "mj" ];
    shell = pkgs.nushell;
  };

  # Build optimization flags
  environment.sessionVariables = {
    RUSTFLAGS = "-C target-cpu=x86-64-v4 -C opt-level=3";
    GOAMD64 = "v4";
    CFLAGS = "-march=x86-64-v4 -O3 -pipe -fno-plt -flto=auto";
    CXXFLAGS = "-march=x86-64-v4 -O3 -pipe -fno-plt -flto=auto";
  };

  # Allow unfree & overlays
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    # useFetchCargoVendor warnings come from upstream nixpkgs packages —
    # harmless deprecation notices that resolve as packages are updated.
    # Suppress via: nixos-rebuild switch ... |& grep -v useFetchCargoVendor
    (final: prev: {
      sequoia-wot = prev.sequoia-wot.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];

  # Firefox
  programs.firefox.enable = true;

  system.stateVersion = "25.11";
}
