{ config, lib, pkgs, ... }:
let
  cfg = config.systemApps.ollama;
  useLocalModel = cfg.modelFile != null;
in
import ../../../lib/mkSystemApp.nix {
  inherit config lib pkgs;
  name = "ollama";

  extraOptions = {
    nvidia = lib.mkEnableOption ''
      NVIDIA (CUDA) acceleration for ollama.
    '';

    amd = lib.mkEnableOption ''
      AMD (ROCm) acceleration for ollama.
    '';

    model = lib.mkOption {
      type = lib.types.str;
      default = "gemma4:12b";
      description = ''
        Model to pull and make available locally. The single source of truth —
        consumers (e.g. agentic-nix, opencode) read their model from here.
        Also the name the model is registered under when modelFile is set.
      '';
    };

    contextLength = lib.mkOption {
      type = lib.types.ints.positive;
      default = 32768;
      description = ''
        Server-wide default context window in tokens (OLLAMA_CONTEXT_LENGTH).
        Ollama's 4096 built-in default truncates agentic workloads (large
        system prompts, tool outputs), and the OpenAI-compatible endpoint
        clients like opencode use has no per-request override — so this has
        to be set on the service. Raise only as far as your VRAM allows;
        KV cache grows linearly with this value.
      '';
    };

    modelFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
      default = null;
      example = "/var/lib/models/gemma4-12b.gguf";
      description = ''
        Locally installed model file (e.g. a .gguf) to import into ollama as
        model instead of pulling it from the registry. A relative path
        resolves against your config source (immutable via the flake copy);
        an absolute path is used in place.
      '';
    };
  };

  extraConfig = {
    assertions = [
      {
        assertion = !(cfg.nvidia && cfg.amd);
        message = "systemApps.ollama: enable either NVIDIA or AMD acceleration, not both.";
      }
    ];

    services.ollama = {
      enable = true;
      package =
        if cfg.nvidia then pkgs.ollama-cuda
        else if cfg.amd then pkgs.ollama-rocm
        else pkgs.ollama;
      environmentVariables.OLLAMA_CONTEXT_LENGTH = toString cfg.contextLength;
    };

    systemd.services.ollama-pull-model = {
      description = "Pull or import the configured ollama model";
      after = [ "ollama.service" ];
      wantedBy = [ "multi-user.target" ];
      environment.HOME = "/var/lib/ollama";
      serviceConfig = {
        Type = "oneshot";
        RuntimeDirectory = "ollama-pull-model";
      };
      script =
        if useLocalModel then ''
          printf 'FROM %s\n' '${toString cfg.modelFile}' > "$RUNTIME_DIRECTORY/Modelfile"
          ${config.services.ollama.package}/bin/ollama create ${cfg.model} -f "$RUNTIME_DIRECTORY/Modelfile"
        '' else ''
          ${config.services.ollama.package}/bin/ollama pull ${cfg.model}
        '';
    } // lib.optionalAttrs useLocalModel {
      unitConfig.RequiresMountsFor = [ (toString cfg.modelFile) ];
    };
  };
}
