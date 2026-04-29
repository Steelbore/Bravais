# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Security and Encryption Tools
{ config, lib, pkgs, gitway, ... }:

{
  options.steelbore.packages.security = {
    enable = lib.mkEnableOption "Security and encryption tools";
  };

  config = lib.mkIf config.steelbore.packages.security.enable {
    environment.systemPackages = with pkgs; [
      # Encryption (Rust preferred)
      age                        # Rust — Modern encryption
      rage                       # Rust — age implementation
      sops                       # Go — Secret management

      # PGP / Sequoia Stack (Rust)
      sequoia-sq                 # Rust — Sequoia CLI
      sequoia-chameleon-gnupg    # Rust — GnuPG drop-in
      sequoia-wot                # Rust — Web of Trust
      sequoia-sqv                # Rust — Signature verifier
      sequoia-sqop               # Rust — Stateless OpenPGP

      # Password Managers
      rbw                        # Rust — Bitwarden CLI
      bitwarden-cli
      bitwarden-desktop
      authenticator              # Rust — 2FA/OTP

      # SSH
      openssh_hpn                              # Includes OpenSSH tooling; avoid colliding with openssh
      gitway.packages.${pkgs.stdenv.hostPlatform.system}.default   # Rust — Steelbore SSH transport for Git (primary path)

      # Backup
      pika-backup                # Rust — Borg frontend

      # Sandboxing
      sydbox                     # Process sandbox / call-policy enforcement

      # Secure Boot
      sbctl                      # Rust — Secure Boot manager
    ];
  };
}
