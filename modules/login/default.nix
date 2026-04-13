# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — greetd + tuigreet Login Manager
{ config, lib, pkgs, steelborePalette, ... }:

let
  mkShellSession = { name, sessionName, exec, comment }: (pkgs.runCommand name {
    passthru.providedSessions = [ sessionName ];
  } ''
    mkdir -p $out/share/wayland-sessions
    cat > $out/share/wayland-sessions/${sessionName}.desktop <<EOF
    [Desktop Entry]
    Name=${name}
    Comment=${comment}
    Exec=${exec}
    Type=Application
    DesktopNames=${sessionName}
    EOF
  '');

  ion-shell-session = mkShellSession {
    name = "Ion Shell";
    sessionName = "ion-shell";
    exec = "${pkgs.ion}/bin/ion";
    comment = "Drop to Ion shell";
  };

  nushell-session = mkShellSession {
    name = "Nushell";
    sessionName = "nushell";
    exec = "${pkgs.nushell}/bin/nu";
    comment = "Drop to Nushell";
  };

  brush-session = mkShellSession {
    name = "Brush Shell";
    sessionName = "brush";
    exec = "${pkgs.brush}/bin/brush";
    comment = "Drop to Brush shell";
  };
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
    kdePackages.plasma-workspace
    ion-shell-session
    nushell-session
    brush-session
  ];

  # Available sessions for greetd environments
  # Note: LeftWM sessions are auto-discovered from xsessions directory
  environment.etc."greetd/environments".text = ''
    niri-session
    start-cosmic
    plasma-session
    plasma-x11-session
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
