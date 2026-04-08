# SPDX-License-Identifier: GPL-3.0-or-later
# Steelbore Lattice — AI Coding Assistants and Tools
{ config, lib, pkgs, stablePkgs, ... }:

{
  options.steelbore.packages.ai = {
    enable = lib.mkEnableOption "AI coding assistants and tools";
  };

  config = lib.mkIf config.steelbore.packages.ai.enable {
    environment.systemPackages = with pkgs; [
      # AI Coding Assistants (Rust preferred)
      aichat                     # Rust — Universal chat REPL
      gemini-cli                 # Rust — Gemini CLI

      # AI Coding Assistants (Other)
      opencode                   # Go — Coding agent
      codex
      github-copilot-cli
      gpt-cli
      mcp-nixos
      stablePkgs.claude-code  # pinned to stable — unstable npm tarball is broken
    ];
  };
}
