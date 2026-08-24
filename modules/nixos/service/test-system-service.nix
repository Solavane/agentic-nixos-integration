{ config, lib, pkgs, ... }:
import ../../../lib/mkSystemApp.nix {
  inherit config lib pkgs;
  name = "test-system-service";
  packages = [ pkgs.test-system-service ];
}
