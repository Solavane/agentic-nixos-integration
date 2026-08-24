# users/example/default.nix
#
# Everything about the *user account* that belongs at the NixOS level:
# the account itself and the wiring of its home-manager configuration.
#
# This file is imported by hosts/example/default.nix. The actual
# home-manager options (app.*, programs.*, home.*) live in ./home.nix
# below — see that file for a guided tour of what agentic-nixos-integration
# adds on the per-user side.
{ ... }:

{
  # --- The account --------------------------------------------------
  # initialPassword exists only so a fresh install is reachable; change
  # it immediately with `passwd` (or use hashedPassword / sops for real
  # deployments).
  users.users.example = {
    isNormalUser = true;
    initialPassword = "password";
  };

  # --- Wire up home-manager for this user ---------------------------
  # Pulls ./home.nix into this user's home-manager evaluation. The
  # flake already loads the shared modules (including
  # agentic-nixos.homeManagerModules.default), so every `app.*` option
  # documented in home.nix is available here without further imports.
  home-manager.users.example.imports = [ ./home.nix ];
}
