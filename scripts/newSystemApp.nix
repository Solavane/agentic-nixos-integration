{ pkgs, writeShellApplication }:
writeShellApplication {
  name = "newSystemApp";
  text = ''
    set -eu

    if [ "$#" -ne 1 ]; then
      echo "Usage: newSystemApp <name>" >&2
      exit 1
    fi

    name="$1"

    if ! [[ "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
      echo "invalid name '$name': use lowercase letters, digits and dashes" >&2
      exit 1
    fi

    dir="modules/nixos/services"
    file="$dir/$name.nix"

    if [ -f "$file" ]; then
      echo "already exists: $file" >&2
      exit 1
    fi

    mkdir -p "$dir"

    cat > "$file" <<EOF
# Scaffolded by 'nix run .#newSystemApp -- $name'
# Assumes the upstream flake input is named 'agentic-nixos'.
{ config, lib, pkgs, inputs, ... }:
import (inputs.agentic-nixos + "/lib/mkSystemApp.nix") {
  inherit config lib pkgs;
  name = "$name";

  # Fill me in per AGENTS.md step 4 — pick one:
  #   native option exists -> native = "$name";  (+ nativeConfig / nativeScope)
  #   otherwise            -> packages = [ pkgs.$name ];
  packages = [ ];
}
EOF

    echo "created $file"
  '';
}
