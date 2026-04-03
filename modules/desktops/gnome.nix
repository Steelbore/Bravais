# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — GNOME Desktop Environment (Wayland)
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
