{ pkgs, writeShellApplication }:
writeShellApplication {
  name = "newApp";
  runtimeInputs = [ pkgs.gnused ];
  text = ''
    name="$1"
    dir="modules/home-manager/programs"
    file="$dir/$name.nix"

    if [ -f "$file" ]; then
      echo "already exists: $file" >&2
      exit 1
    fi

    mkdir -p "$dir"
    cat > "$file" <<EOF
{ config, lib, pkgs, ... }:
import ../../../lib/mkApp.nix {
  inherit config lib pkgs;
  name = "$name";
  packages = [ pkgs.$name ];
}
EOF

    echo "created $file"
  '';
}
