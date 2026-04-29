# SPDX-License-Identifier: GPL-3.0-or-later
{
  description = "Lattice — A Steelbore NixOS Distribution";

  inputs = {
    # Core (Stable — 25.11)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager (Stable)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Core (Unstable — Rolling)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager (Unstable)
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Declarative Flatpak management
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Gitway — Steelbore's SSH transport for Git (tracks main)
    gitway.url = "github:Steelbore/Gitway";
    gitway.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixpkgs-unstable,
      home-manager-unstable,
      nix-flatpak,
      gitway,
      ...
    }:
    let
      system = "x86_64-linux";

      # Steelbore color palette as a reusable attribute set
      steelborePalette = {
        voidNavy    = "#000027";
        moltenAmber = "#D98E32";
        steelBlue   = "#4B7EB0";
        radiumGreen = "#50FA7B";
        redOxide    = "#FF5C5C";
        liquidCool  = "#8BE9FD";
      };

      # ── Channel selector ──────────────────────────────────────────────────
      # Maps a channel name to the correct nixpkgs and home-manager input.
      channels = {
        stable   = { pkgs = nixpkgs;          hm = home-manager; };
        unstable = { pkgs = nixpkgs-unstable; hm = home-manager-unstable; };
      };

      # ── mkLattice ────────────────────────────────────────────────────────
      # Build a Lattice NixOS configuration for a given x86-64 march level
      # and nixpkgs channel.
      #
      # Usage:  nixos-rebuild switch --flake .#lattice-v3
      #         nixos-rebuild switch --flake .#lattice-unstable-v3
      #
      #   channel — "stable" (25.11) or "unstable" (rolling)
      #   v1 — baseline x86-64 (SSE2)        broadest compatibility
      #   v2 — SSE4.2 / POPCNT / CX16        ~2008+ CPUs
      #   v3 — AVX2 / BMI1/2 / FMA / MOVBE   ~2013+ CPUs (CachyOS default)
      #   v4 — AVX-512F/BW/CD/DQ/VL          Ice Lake+ / Zen 4+
      mkLattice =
        { marchLevel
        , channel ? "stable"
        }:
        let
          ch = channels.${channel};
        in
        ch.pkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit steelborePalette gitway; };
          modules = [
            # External modules
            ch.hm.nixosModules.home-manager
            nix-flatpak.nixosModules.nix-flatpak

            # Lattice modules
            ./hosts/lattice
            ./modules/core
            ./modules/theme
            ./modules/hardware
            ./modules/desktops
            ./modules/login
            ./modules/packages

            # Profile + Home Manager integration
            {
              steelbore.hardware.intel.marchLevel = marchLevel;

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit steelborePalette gitway; };
              home-manager.users.mj = import ./users/mj/home.nix;
            }
          ];
        };

    in
    {
      nixosConfigurations = {
        # ── Stable (nixos-25.11) ────────────────────────────────────────────
        # Default — AVX-512 (same as lattice-v4)
        lattice    = mkLattice { marchLevel = "v4"; };

        # Explicit stable profiles
        lattice-v1 = mkLattice { marchLevel = "v1"; };   # baseline x86-64    (SSE2)
        lattice-v2 = mkLattice { marchLevel = "v2"; };   # x86-64-v2          (SSE4.2)
        lattice-v3 = mkLattice { marchLevel = "v3"; };   # x86-64-v3  AVX2    (CachyOS default)
        lattice-v4 = mkLattice { marchLevel = "v4"; };   # x86-64-v4  AVX-512 (Lattice default)

        # ── Unstable (nixos-unstable) ───────────────────────────────────────
        # Default unstable — AVX-512 (same as lattice-unstable-v4)
        lattice-unstable    = mkLattice { marchLevel = "v4"; channel = "unstable"; };

        # Explicit unstable profiles
        lattice-unstable-v1 = mkLattice { marchLevel = "v1"; channel = "unstable"; };
        lattice-unstable-v2 = mkLattice { marchLevel = "v2"; channel = "unstable"; };
        lattice-unstable-v3 = mkLattice { marchLevel = "v3"; channel = "unstable"; };
        lattice-unstable-v4 = mkLattice { marchLevel = "v4"; channel = "unstable"; };
      };
    };
}
