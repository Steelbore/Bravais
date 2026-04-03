# SPDX-License-Identifier: GPL-3.0-or-later
{
  description = "Lattice — A Steelbore NixOS Distribution";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional flake inputs
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    # Steelbore color palette as a reusable attribute set
    steelborePalette = {
      voidNavy     = "#000027";
      moltenAmber  = "#D98E32";
      steelBlue    = "#4B7EB0";
      radiumGreen  = "#50FA7B";
      redOxide     = "#FF5C5C";
      liquidCool   = "#8BE9FD";
    };
  in {
    nixosConfigurations.lattice = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit steelborePalette;
      };
      modules = [
        # External modules
        home-manager.nixosModules.home-manager

        # Lattice modules
        ./hosts/lattice
        ./modules/core
        ./modules/theme
        ./modules/hardware
        ./modules/desktops
        ./modules/login
        ./modules/packages

        # Home Manager integration
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit steelborePalette; };
          home-manager.users.mj = import ./users/mj/home.nix;
        }
      ];
    };
  };
}
