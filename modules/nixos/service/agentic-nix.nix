{ config, lib, pkgs, ... }:
let
  cfg = config.systemApps.agentic-nix;
in
import ../../../lib/mkSystemApp.nix {
  inherit config lib pkgs;
  name = "agentic-nix";

  extraOptions = {
    backend = lib.mkOption {
      type = lib.types.enum [ "ollama" "claude-api" ];
      default = "ollama";
      description = "Which AI backend agentic-nix drives opencode with.";
    };
  };

  packages = [
    (pkgs.callPackage ../../../scripts/agentic-nix.nix {
      inherit (cfg) backend;
      model = config.systemApps.ollama.model;
    })
  ];

  extraConfig = lib.mkIf (cfg.backend == "ollama") {
    systemApps.ollama.enable = lib.mkDefault true;
  };
}
