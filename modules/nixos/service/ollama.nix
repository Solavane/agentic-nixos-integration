{ config, lib, pkgs, ... }:
let
  cfg = config.systemApps.ollama;
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
    };
  };
}
