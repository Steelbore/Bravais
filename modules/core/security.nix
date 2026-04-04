# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Security Configuration
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Disable standard sudo (C implementation)
  security.sudo.enable = false;

  # Enable sudo-rs (Rust implementation — memory-safe)
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };

  # Polkit for privilege escalation
  security.polkit.enable = true;

  # SSH agent (for SSH key-based git signing)
  programs.ssh.startAgent = true;
  services.gnome.gcr-ssh-agent.enable = false;

  # Tmpfiles rules
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root -"
    "d /var/tmp 1777 root root -"
  ];
}
