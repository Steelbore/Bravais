# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — Intel CPU Optimizations
{ config, lib, pkgs, ... }:

{
  options.steelbore.hardware.intel = {
    enable = lib.mkEnableOption "Intel CPU optimizations";
  };

  config = lib.mkIf config.steelbore.hardware.intel.enable {
    boot.kernelModules = [ "kvm-intel" ];

    hardware.cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Build optimization flags for x86-64-v4 (AVX-512)
    environment.sessionVariables = {
      RUSTFLAGS = "-C target-cpu=x86-64-v4 -C opt-level=3";
      GOAMD64 = "v4";
      CFLAGS = "-march=x86-64-v4 -O3 -pipe -fno-plt -flto=auto";
      CXXFLAGS = "-march=x86-64-v4 -O3 -pipe -fno-plt -flto=auto";
    };
  };
}
