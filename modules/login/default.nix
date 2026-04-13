# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — greetd + tuigreet Login Manager
{ config, lib, pkgs, steelborePalette, ... }:

let
  ion-shell-session = pkgs.writeTextDir "share/wayland-sessions/ion-shell.desktop" ''
    [Desktop Entry]
    Name=Ion Shell
    Comment=Drop to Ion shell
    Exec=${pkgs.ion}/bin/ion
    Type=Application
    DesktopNames=ion-shell
  '';

  nushell-session = pkgs.writeTextDir "share/wayland-sessions/nushell-session.desktop" ''
    [Desktop Entry]
    Name=Nushell
    Comment=Drop to Nushell
    Exec=${pkgs.nushell}/bin/nu
    Type=Application
    DesktopNames=nushell
  '';

  brush-session = pkgs.writeTextDir "share/wayland-sessions/brush-session.desktop" ''
    [Desktop Entry]
    Name=Brush Shell
    Comment=Drop to Brush shell
    Exec=${pkgs.brush}/bin/brush
    Type=Application
    DesktopNames=brush
  '';
in
{
  # greetd display manager with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --time-format "%Y-%m-%d %H:%M:%S" \
            --remember \
            --remember-session \
            --asterisks \
            --greeting "STEELBORE :: LATTICE" \
            --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions
        '';
        user = "greeter";
      };
    };
  };

  # Ensure session packages are registered
  # Note: leftwm is not included here because it lacks passthru.providedSessions.
  # LeftWM sessions are registered automatically via services.xserver.windowManager.leftwm.enable.
  # GNOME sessions are registered automatically via services.desktopManager.gnome.enable.
  services.displayManager.sessionPackages = with pkgs; [
    niri
    cosmic-session
    ion-shell-session
    nushell-session
    brush-session
  ];

  # Available sessions for greetd environments
  # Note: LeftWM sessions are auto-discovered from xsessions directory
  environment.etc."greetd/environments".text = ''
    niri-session
    start-cosmic
    gnome-session
    ion
    nu
    brush
  '';

  environment.systemPackages = with pkgs; [
    tuigreet
  ];

  # PAM configuration for greetd
  security.pam.services.greetd.enableGnomeKeyring = true;
}
