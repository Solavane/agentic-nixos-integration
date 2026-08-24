{ config, lib, pkgs, ... }:
import ../../../lib/mkSystemApp.nix {
  inherit config lib pkgs;
  name = "$name";
  packages = [ pkgs.$name ];
}
