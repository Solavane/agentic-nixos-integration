{ config, lib, pkgs
, name
, extraOptions ? {}
, packages ? []
, native ? null          # e.g. "steam"
, nativeScope ? "programs"  # "programs" or "services" — steam vs e.g. tailscale
, nativeConfig ? {}
, extraConfig ? {}
}:
let cfg = config.systemApps.${name};
in {
  options.systemApps.${name} = { enable = lib.mkEnableOption name; } // extraOptions;
  config = lib.mkIf cfg.enable (lib.mkMerge ([
    { environment.systemPackages = packages; }
    extraConfig
  ] ++ lib.optional (native != null) {
    ${nativeScope}.${native} = { enable = true; } // nativeConfig;
  }));
}
