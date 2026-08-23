# Installing or configuring software on this system

This repo uses a convention: every installable app/service exposes a single
toggle, `apps.<name>.enable` (home-manager, per-user) or
`systemApps.<name>.enable` (NixOS, system-wide). Follow these steps in order.

## 1. Decide scope
- Runs as a normal user program, no root/daemon needed → home-manager (`apps.*`)
- Needs a systemd service, kernel module, or system-wide state (Steam, ollama,
  networking) → NixOS (`systemApps.*`)

## 2. Check for a native option first
Before writing a package list, check if a dedicated option already exists:
- home-manager: `programs.<name>.enable`
- NixOS: `programs.<name>.enable` or `services.<name>.enable`

Use the mcp-nixos MCP server to search — do not guess option paths from memory,
NixOS/home-manager option names are frequently non-obvious and confident
wrong guesses are common.

## 3. Scaffold the module
Do not hand-write the boilerplate. Run the generator:
- home-manager app: `nix run .#newApp -- <name>`
- NixOS app/service: `nix run .#newSystemApp -- <name>`

This drops a file already calling `mkApp`/`mkSystemApp` correctly at
`modules/home-manager/programs/<name>.nix` or
`modules/nixos/programs/<name>.nix`.

## 4. Fill in the generated file
- If a native option exists (step 2): set `native = "<name>";` and pass any
  settings via `nativeConfig = { ... };`.
- If no native option exists: set `packages = [ pkgs.<name> ];`.
- If the package comes from a flake input rather than nixpkgs (check
  `flake.nix` inputs first), build it in `packages` accordingly — do not
  assume `pkgs.<name>` exists just because a flake input with that name does.
- Extra options (e.g. blocklists, config values) go in `extraOptions`.
  Config that reads those options goes in `extraConfig`.

## 5. Enable it on a host
Add `apps.<name>.enable = true;` or `systemApps.<name>.enable = true;` to the
relevant host's config under `hosts/<hostname>/` (or `users/<user>/` for
home-manager).

## 6. Validate before applying
Always run `nixos-rebuild build --flake .` and confirm it succeeds before
`switch`. Never skip this step.
