{ pkgs, writeShellApplication }:
writeShellApplication {
  name = "newApp";
  text = ''
    set -eu

    if [ "$#" -ne 1 ]; then
      echo "Usage: newApp <name>" >&2
      exit 1
    fi

    name="$1"

    if ! [[ "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
      echo "invalid name '$name': use lowercase letters, digits and dashes" >&2
      exit 1
    fi

    dir="modules/home-manager/programs"
    file="$dir/$name.nix"

    if [ -f "$file" ]; then
      echo "already exists: $file" >&2
      exit 1
    fi

    mkdir -p "$dir"

    cat > "$file" <<EOF
# Scaffolded by 'nix run .#newApp -- $name'
# Assumes the upstream flake input is named 'agentic-nixos'.
{ config, lib, pkgs, inputs, ... }:
import (inputs.agentic-nixos + "/lib/mkApp.nix") {
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
