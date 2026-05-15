# SPDX-License-Identifier: GPL-3.0-or-later
# Spacecraft Software Bravais — Fingerprint Reader Support
{ config, lib, pkgs, ... }:

{
  options.spacecraft.hardware.fingerprint = {
    enable = lib.mkEnableOption "Fingerprint reader support";
  };

  config = lib.mkIf config.spacecraft.hardware.fingerprint.enable {
    services.fprintd.enable = true;

    environment.systemPackages = [ pkgs.fprintd ];
  };
}
