# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Login Manager (greetd + tuigreet)
{ config, lib, pkgs, ... }:

let
  # Session selector script
  sessionScript = pkgs.writeShellScriptBin "steelbore-session" ''
    echo "╔════════════════════════════════════════╗"
    echo "║     STEELBORE :: SESSION SELECTOR      ║"
    echo "╠════════════════════════════════════════╣"
    echo "║  1) Niri      (Wayland) — Recommended  ║"
    echo "║  2) COSMIC    (Wayland)                ║"
    echo "║  3) GNOME     (Wayland)                ║"
    echo "║  4) LeftWM    (X11)                    ║"
    echo "╚════════════════════════════════════════╝"
    read -p "Select [1-4]: " choice

    case $choice in
      1) exec niri-session ;;
      2) exec start-cosmic ;;
      3) exec gnome-session ;;
      4) exec startx /usr/bin/env leftwm ;;
      *) echo "Invalid selection"; exit 1 ;;
    esac
  '';
in
{
  # greetd configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Default to Niri (Steelbore Standard)
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri-session";
        user = "mj";
      };
    };
  };

  # Packages
  environment.systemPackages = [
    pkgs.greetd
    pkgs.tuigreet
    pkgs.lemurs
    sessionScript
  ];

  # Available sessions
  services.displayManager.sessionPackages = with pkgs; [
    niri
  ];
}
