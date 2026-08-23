# scripts/agentic-nix.nix
{ lib, pkgs, writeShellApplication, backend ? "claude-api", model ? null }:
writeShellApplication {
  name = "agentic-nix";
  runtimeInputs = [ pkgs.opencode ] ++ lib.optional (backend == "ollama") pkgs.ollama;
  text = ''
    NIXCONFIG_DIR="''${NIXCONFIG_DIR:-$HOME/nixconfig}"
    cd "$NIXCONFIG_DIR" || { echo "no config at $NIXCONFIG_DIR"; exit 1; }

    opencode run "$1"

    nixos-rebuild build --flake . || { echo "build failed, not switching"; exit 1; }

    if [ "''${AGENTIC_NIX_DRY_RUN:-0}" = "1" ]; then
      echo "dry run: build succeeded, not switching"
      exit 0
    fi

    nixos-rebuild switch --flake .
  '';
}
