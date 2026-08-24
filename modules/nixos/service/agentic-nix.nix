{ config, lib, pkgs, ... }:
let
  cfg = config.systemApps.agentic-nix;
  useLocalModel = cfg.ollama.modelFile != null;
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
      description = ''
        Model to pull and use when backend = ollama. Also the name the model is
        registered under when ollama.modelFile is set.
      '';
    };
    ollama.modelFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
      default = null;
      example = "/var/lib/models/gemma4-12b.gguf";
      description = ''
        Locally installed model file (e.g. a .gguf) to import into ollama as
        cfg.ollama.model instead of pulling it from the registry. A relative
        path resolves against your config source (immutable via the flake
        copy); an absolute path is used in place.
      '';
    };
  };

  packages = [
    (pkgs.callPackage ../../../scripts/agentic-nix.nix {
      inherit (cfg) backend;
      model = cfg.ollama.model;
    })
  ];

  extraConfig = lib.mkIf (cfg.backend == "ollama") {
    systemApps.ollama.enable = lib.mkDefault true;

    systemd.services.agentic-nix-pull-model = {
      description = "Pull or import the configured ollama model for agentic-nix";
      after = [ "ollama.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = "agentic-nix-pull-model";
      };
      script =
        if useLocalModel then ''
          printf 'FROM %s\n' '${toString cfg.ollama.modelFile}' > "$RUNTIME_DIRECTORY/Modelfile"
          ${pkgs.ollama}/bin/ollama create ${cfg.ollama.model} -f "$RUNTIME_DIRECTORY/Modelfile"
        '' else ''
          ${pkgs.ollama}/bin/ollama pull ${cfg.ollama.model}
        '';
    } // lib.optionalAttrs useLocalModel {
      unitConfig.RequiresMountsFor = [ (toString cfg.ollama.modelFile) ];
    };
  };
}
