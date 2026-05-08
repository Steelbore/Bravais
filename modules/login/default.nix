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

  # Unified `start-<de>` launchers. Every desktop in Lattice exposes the same
  # naming pattern so users (and greetd's environment list) can launch any
  # session without remembering upstream session-binary names.
  #
  # `start-cosmic` is intentionally not defined here — `pkgs.cosmic-session`
  # already ships `bin/start-cosmic` (with login-shell env loading and
  # systemd-unit reset that we don't want to skip), and the cosmic NixOS
  # module pulls cosmic-session into systemPackages. Defining our own would
  # collide on /run/current-system/sw/bin/start-cosmic.
  mkStartWrapper = name: command: pkgs.writeShellScriptBin "start-${name}" ''
    exec ${command} "$@"
  '';

  start-gnome      = mkStartWrapper "gnome"      "${pkgs.gnome-session}/bin/gnome-session";
  start-plasma     = mkStartWrapper "plasma"     "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland";
  start-plasma-x11 = mkStartWrapper "plasma-x11" "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-x11";
  start-niri       = mkStartWrapper "niri"       "${pkgs.niri}/bin/niri-session";
  # pkgs.xorg.xinit emits a deprecation warning on unstable (renamed to
  # pkgs.xinit) but is the canonical attribute on stable 25.11. Same
  # stable/unstable split as xfce4-terminal — see CLAUDE.md known constraint #5.
  start-leftwm     = mkStartWrapper "leftwm"     "${pkgs.xorg.xinit}/bin/startx ${pkgs.leftwm}/bin/leftwm";
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
  # All desktops share a unified `start-<de>` naming scheme.
  environment.etc."greetd/environments".text = ''
    start-niri
    start-cosmic
    start-plasma
    start-plasma-x11
    start-gnome
    start-leftwm
    nu
    brush
    ion
  '';

  environment.systemPackages = with pkgs; [
    tuigreet
  ] ++ [
    start-gnome
    start-plasma
    start-plasma-x11
    start-niri
    start-leftwm
  ];

  # PAM configuration for greetd
  security.pam.services.greetd.enableGnomeKeyring = true;
}
