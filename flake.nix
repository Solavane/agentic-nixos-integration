{
  description = "Agentic NixOS Base flake for desktop LLM integration and installation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # --- library functions, consumed by modules ---
      lib = {
        mkApp = import ./lib/mkApp.nix;
        mkSystemApp = import ./lib/mkSystemApp.nix;
      };

      # --- reusable modules, exposed for personal configs to import ---
      homeManagerModules.default = ./modules/home-manager;
      nixosModules.default = ./modules/nixos;

      # --- scaffold template for `nix flake init -t` ---
      templates.default = {
        path = ./template;
        description = "Agentic NixOS config scaffold";
      };

      # --- bootstrap/generator scripts, runnable with `nix run` ---
      apps = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          newApp = {
            type = "app";
            program = "${pkgs.callPackage ./scripts/newApp.nix {}}/bin/newApp";
          };
          newSystemApp = {
            type = "app";
            program = "${pkgs.callPackage ./scripts/newSystemApp.nix {}}/bin/newSystemApp";
          };
        });
    };
}
