{
  description = "My NixOS config, built on agentic-nixos-integration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  nix-core.url = "path:/home/solavane/agentic-nixos-integration";
    nix-core.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nix-core, home-manager, ... }@inputs:
  let
    mkHost = hostname: system: { desktop ? false }:
    nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
        isDesktop = desktop;
      };
      modules = [
        ./hosts/${hostname}/default.nix
        ./modules/nixos/default.nix
        nix-core.nixosModules.default

        ({ config, lib, ... }: {
          options.nixconf.isDesktop = lib.mkEnableOption "Weather or not host is for desktop use";
          config.nixconf.isDesktop = lib.mkDefault desktop;
        })

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              ./modules/home-manager/default.nix
              nix-core.homeManagerModules.default
            ];
            extraSpecialArgs = { inherit inputs; };
            backupFileExtension = "bkup-home-manager-${toString inputs.self.lastModifiedDate}";
          };
        }
      ];
    };
  in {
    nixosConfigurations = {
      example = mkHost "example" "x86_64-linux" { desktop = true; };
    };
  };
}
