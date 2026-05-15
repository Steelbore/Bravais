# SPDX-License-Identifier: GPL-3.0-or-later
# Spacecraft Software Bravais — Text Editors and IDEs
{ config, lib, pkgs, ... }:

{
  options.spacecraft.packages.editors = {
    enable = lib.mkEnableOption "Text editors and IDEs";
  };

  config = lib.mkIf config.spacecraft.packages.editors.enable {
    environment.systemPackages = with pkgs; [
      # Linting
      markdownlint-cli2           # Markdown linter

      # TUI Editors (Rust preferred)
      helix                      # Rust — Modal editor
      amp                        # Rust — Vim-like
      msedit                     # Rust — MS-DOS style

      # TUI Editors (Standard)
      neovim
      vim
      mg                         # Micro Emacs
      mc                         # Midnight Commander

      # GUI Editors (Rust preferred)
      # zed-editor-fhs moved to users/mj/home.nix (unstable channel via HM).
      lapce                      # Rust — Lightning fast
      neovide                    # Rust — Neovim GUI
      cosmic-edit                # Rust — COSMIC editor

      # GUI Editors (Standard)
      emacs-pgtk
      # vscode-fhs moved to users/mj/home.nix (unstable channel via HM).
      gedit
    ];
  };
}
