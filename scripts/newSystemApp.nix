{ pkgs, writeShellApplication }:
writeShellApplication {
  name = "newSystemApp";
  runtimeInputs = [ pkgs.gnused ];
  text = ''
    set -eu
    name="$1"

    if [ $# -lt 1 ]; then
      echo "Usage: newSystemApp <name>" >&2
      exit 1
    fi

    if [ "$#" -gt 1 ]; then
      echo "newSystemApp takes only one argument: <name>" >&2
      exit 1
    fi

    dir="modules/nixos/service"
    file="$dir/$name.nix"

    if [ -f "$file" ]; then
      echo "already exists: $file" >&2
      exit 1
    fi

    mkdir -p "$dir"

    # Write Nix module using sed for variable substitution (more portable)
    TMPFILE=$(mktemp)
    cat > "$TMPFILE" <<INNEREOF
{ config, lib, pkgs, ... }:
import ../../../lib/mkSystemApp.nix {
  inherit config lib pkgs;
  name = "PLACEHOLDER";
  packages = [ pkgs.PLACEHOLDER ];
}
INNEREOF

    sed -i "s/PLACEHOLDER/$name/g" "$TMPFILE"
    cp "$TMPFILE" "$file"
    rm -f "$TMPFILE"

    echo "created $file"
  '';
}
