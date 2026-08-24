{ config, lib, pkgs, ... }:
import ../../../lib/mkApp.nix {
  inherit config lib pkgs;
  name = "my-custom-app";
  packages = [ pkgs.my-custom-app ];
}
