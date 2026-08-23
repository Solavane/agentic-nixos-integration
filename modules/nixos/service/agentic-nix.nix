# modules/nixos/services/agentic-nix.nix
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
    ollama.model = lib.mkOption {
      type = lib.types.str;
      default = "gemma4:12b";
      description = "Model to pull and use when backend = ollama.";
    };
  };

  packages = [
    (pkgs.callPackage ../../../scripts/agentic-nix.nix {
      inherit (cfg) backend;
      model = cfg.ollama.model;
    })
  ];

  extraConfig = lib.mkIf (cfg.backend == "ollama") {
    services.ollama.enable = true;

    systemd.services.agentic-nix-pull-model = {
      description = "Pull the configured ollama model for agentic-nix";
      after = [ "ollama.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = "${pkgs.ollama}/bin/ollama pull ${cfg.ollama.model}";
    };
  };
}
