# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Bravais — Office and Productivity Applications
{ config, lib, pkgs, ... }:

{
  options.steelbore.packages.productivity = {
    enable = lib.mkEnableOption "Office and productivity applications";
  };

  config = lib.mkIf config.steelbore.packages.productivity.enable {
    environment.systemPackages = with pkgs; [
      # Knowledge Management (Rust preferred)
      appflowy                   # Rust — Open source Notion
      affine                     # Rust — Knowledge base
      nb                         # CLI note-taking & knowledge base

      # Office Suites
      libreoffice-fresh
      onlyoffice-desktopeditors

      # Utilities
      qalculate-gtk

      # Communication (Rust preferred)
fractal                    # Rust — Matrix GUI
      newsflash                  # Rust — RSS reader
      tutanota-desktop
      onedriver                  # Go — OneDrive
    ];
  };
}
