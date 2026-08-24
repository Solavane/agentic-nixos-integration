{ config, lib, pkgs, osConfig ? null, ... }:
let
  cfg = config.app.opencode;
  ollamaEnabled = osConfig != null && osConfig.services.ollama.enable or false;
  useHuggingface = cfg.huggingface.enable;
  useOllama = !useHuggingface && ollamaEnabled;
in
import ../../../lib/mkApp.nix {
  inherit config lib pkgs;
  name = "opencode";
  native = "opencode";

  extraOptions = {
    ollama.model = lib.mkOption {
      type = lib.types.str;
      default = "gemma4:12b";
      description = "Ollama model opencode uses when ollama is enabled.";
    };

    huggingface.enable = lib.mkEnableOption ''
      a custom LLM from HuggingFace via the Inference Providers router.
      Needs HUGGINGFACE_API_KEY in the environment.
    '';

    huggingface.model = lib.mkOption {
      type = lib.types.str;
      default = "meta-llama/Llama-3.3-70B-Instruct";
      description = "HuggingFace model id opencode uses when huggingface is enabled.";
    };

    huggingface.baseURL = lib.mkOption {
      type = lib.types.str;
      default = "https://router.huggingface.co/v1";
      description = "OpenAI-compatible endpoint for the HuggingFace provider.";
    };
  };

  extraConfig = lib.mkMerge [
    (lib.mkIf useOllama {
      programs.opencode.settings = {
        model = "ollama/${cfg.ollama.model}";
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options.baseURL = "http://127.0.0.1:11434/v1";
          models.${cfg.ollama.model}.name = cfg.ollama.model;
        };
      };
    })

    (lib.mkIf useHuggingface {
      programs.opencode.settings = {
        model = "huggingface/${cfg.huggingface.model}";
        provider.huggingface = {
          npm = "@ai-sdk/openai-compatible";
          name = "HuggingFace";
          options = {
            baseURL = cfg.huggingface.baseURL;
            apiKey = "{env:HUGGINGFACE_API_KEY}";
          };
          models.${cfg.huggingface.model}.name = cfg.huggingface.model;
        };
      };
    })
  ];
}
