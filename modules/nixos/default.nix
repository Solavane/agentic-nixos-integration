{ lib, ... }:
let
  collectNixFiles = dir:
    let
      entries = builtins.readDir dir;
    in
    lib.concatLists (lib.mapAttrsToList (name: type:
      let path = dir + "/${name}"; in
      if type == "directory" then
        collectNixFiles path
      else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
        [ path ]
      else
        []
    ) entries);
in
{
  imports = collectNixFiles ./.;
}
