{
  description = "My NixOS config, built on agentic-nixos-integration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    agentic-nixos.url = "path:/home/solavane/agentic-nixos-integration";
    agentic-nixos.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, agentic-nixos, home-manager, ... }@inputs:
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
        agentic-nixos.nixosModules.default

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
              agentic-nixos.homeManagerModules.default
            ];
            extraSpecialArgs = { inherit inputs; };
            backupFileExtension = "bkup-home-manager-${toString inputs.self.lastModifiedDate}";
          };
        }
      ];
    };
  in {
    # re-export the generators so `nix run .#newApp -- <name>` works here too
    inherit (agentic-nixos) apps;

    nixosConfigurations = {
      example = mkHost "example" "x86_64-linux" { desktop = true; };
    };
  };
}
