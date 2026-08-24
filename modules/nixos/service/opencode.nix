{ config, lib, pkgs, ... }:
import ../../../lib/mkSystemApp.nix {
  inherit config lib pkgs;
  name = "opencode";
  packages = [ pkgs.opencode ];
}
