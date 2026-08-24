{ config, lib, pkgs
, name
, extraOptions ? {}
, packages ? []
, native ? null
, nativeScope ? "programs"  # parity with mkSystemApp — home-manager has services.* too (e.g. gpg-agent)
, nativeConfig ? {}
, extraConfig ? {}
}:

let
  cfg = config.app.${name};
in
{
  options.app.${name} = {
    enable = lib.mkEnableOption name;
  } // extraOptions;

  config = lib.mkIf cfg.enable (lib.mkMerge ([
    { home.packages = packages; }
    extraConfig
  ] ++ lib.optional (native != null) {
    ${nativeScope}.${native} = { enable = true; } // nativeConfig;
  }));
}
