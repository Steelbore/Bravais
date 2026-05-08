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

  # SSH agent — provided by gitway-agent (NixOS module from the gitway flake;
  # imported in flake.nix). Disable system OpenSSH ssh-agent.service so it
  # doesn't race gitway-agent for $SSH_AUTH_SOCK. The OpenSSH CLI tools remain
  # available as a fallback for non-Git SSH workflows.
  programs.ssh.startAgent = false;
  services.gnome.gcr-ssh-agent.enable = false;   # guard against GCR clobbering the socket

  services.gitway-agent.enable = true;

  # nixosModules.default doesn't expose defaultLifetime; restore the 24 h TTL
  # (parity with the previous home-manager configuration) by appending `-t 86400`.
  systemd.user.services.gitway-agent.serviceConfig.ExecStart = lib.mkForce
    "${config.services.gitway-agent.package}/bin/gitway agent start -D -s -a %t/gitway-agent.sock -t 86400";

  # Tmpfiles rules
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root -"
    "d /var/tmp 1777 root root -"
  ];
}
