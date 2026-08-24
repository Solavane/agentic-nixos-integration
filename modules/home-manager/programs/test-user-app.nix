{ config, lib, pkgs, ... }:
import ../../../lib/mkApp.nix {
  inherit config lib pkgs;
  name = "test-user-app";
  packages = [ pkgs.test-user-app ];
}
