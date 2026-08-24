{ pkgs, writeShellApplication }:
writeShellApplication {
  name = "newApp";
  runtimeInputs = [ pkgs.gnused ];
  text = ''
    set -eu

    if [ $# -lt 1 ]; then
      echo "Usage: newApp <name> [--native <pkg>] [--extraConfig <nix-code>] [--extraOptions <option-path>:<type>:default]" >&2
      exit 1
    fi

    name="$1"
    native=""
    extraConfig=""
    declare -A extraOptions=()

    # Parse optional arguments
    shift
    while [ $# -gt 0 ]; do
      case "$1" in
        --native)
          native="$2"
          shift
          shift
          ;;
        --extraConfig)
          extraConfig="$2"
          shift
          shift
          ;;
        --extraOptions)
          optDef="$2"
          # Parse as "option.path:type:default"
          IFS=':' read -r optPath optType optDefault <<< "$optDef"
          if [ -n "$optPath" ] && [ -n "$optType" ]; then
            extraOptions[$optPath]="$optType:$optDefault"
          fi
          shift
          shift
          ;;
        *)
          echo "Unknown option: $1" >&2
          exit 1
          ;;
      esac
    done

    dir="modules/home-manager/programs"
    file="$dir/$name.nix"

    if [ -f "$file" ]; then
      echo "already exists: $file" >&2
      exit 1
    fi

    mkdir -p "$dir"

    TMPFILE=$(mktemp)

    {
    if [ -n "$native" ]; then
      nativeScope="programs"
      printf 'import ../../../lib/mkApp.nix {\n' >> "$TMPFILE"
      printf('  inherit config lib pkgs;\n') >> "$TMPFILE"
      printf('  name = "%s";\n' "$name") >> "$TMPFILE"
      if [ -n "$extraConfig" ]; then
        printf '  extraConfig = { %s };\n' "$extraConfig" >> "$TMPFILE"
      else
        printf '  extraConfig = {}; // add custom config here\n') >> "$TMPFILE"
      fi
    elif [ ${#extraOptions[@]} -gt 0 ]; then
      # User defined options via --extraOptions flag
      printf 'import ../../../lib/mkApp.nix {\n' >> "$TMPFILE"
      printf('  inherit config lib pkgs;\n') >> "$TMPFILE"
      printf('  name = "%s";\n' "$name") >> "$TMPFILE"
      printf('  extraOptions = { %s };\n' "$(IFS=','; echo "${extraOptions[*]}")") >> "$TMPFILE"
    else
      # Default: use packages with native scope
      printf 'import ../../../lib/mkApp.nix {\n' >> "$TMPFILE"
      printf('  inherit config lib pkgs;\n') >> "$TMPFILE"
      printf('  name = "%s";\n' "$name") >> "$TMPFILE"
      if [ -n "$extraConfig" ]; then
        printf('  extraConfig = { %s };\n' "$extraConfig") >> "$TMPFILE"
      else
        printf '  extraConfig = {}; // add custom config here\n') >> "$TMPFILE"
      fi
    fi
    printf '}\n' >> "$TMPFILE"

    echo "created $file"

    # Replace PLACEHOLDER with actual name/values using sed
    sed -i "s/PLACEHOLDER_$name/$name/g" "$TMPFILE" 2>/dev/null || true
    
    cat "$TMPFILE" > "$file"
    rm -f "$TMPFILE"

    }
  '';
}
