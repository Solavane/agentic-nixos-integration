# Installing or configuring software on this system

This repo uses a convention: every installable app/service exposes a single
toggle, `app.<name>.enable` (home-manager, per-user) or
`systemApps.<name>.enable` (NixOS, system-wide). Follow these steps in order.

## 0. Read the examples first

The example config is written as living documentation and shows every option
the bundled modules introduce:

- `hosts/example/default.nix` — all `systemApps.*` options (ollama,
  agentic-nix) explained inline
- `users/example/default.nix` + `users/example/home.nix` — user account,
  home-manager wiring, and all `app.*` options (opencode)

When you add a new module here, extend the matching example file with its new
options so the docs stay true. When unsure how an option behaves, trust the
example over your memory.

## 1. Decide scope

- Runs as a normal user program, no root/daemon needed → home-manager (`app.*`)
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

As a host/user you only ever *set* options; `native`, `nativeConfig`,
`packages`, etc. are parameters only module authors pass to
`mkApp`/`mkSystemApp`:

- If a native option exists (step 2): set `native = "<name>";` and pass any
  settings via `nativeConfig = { ... };`. If it's a service rather than a
  program (`services.<name>.enable`), also set `nativeScope = "services";`
  (works in both `mkApp` and `mkSystemApp`).
- If no native option exists: set `packages = [ pkgs.<name> ];`.
- If the package comes from a flake input rather than nixpkgs (check
  `flake.nix` inputs first), build it in `packages` accordingly — do not
  assume `pkgs.<name>` exists just because a flake input with that name does.
- Extra options users can toggle go in `extraOptions`; config that reads them
  goes in `extraConfig`. Document each new option in the matching example file
  (step 0).

### Options introduced by the bundled modules

| Option | Type / default | Effect |
| --- | --- | --- |
| `systemApps.ollama.enable` | bool | Runs the ollama daemon; pulls/imports one model on boot |
| `systemApps.ollama.nvidia` | bool | CUDA build (`ollama-cuda`) |
| `systemApps.ollama.amd` | bool | ROCm build (`ollama-rocm`); build fails if both nvidia+amd |
| `systemApps.ollama.model` | str, `"gemma4:12b"` | Model name — single source of truth, read by opencode & agentic-nix |
| `systemApps.ollama.contextLength` | int, `32768` | `OLLAMA_CONTEXT_LENGTH`; KV cache grows linearly with it |
| `systemApps.ollama.modelFile` | nullOr path/str, `null` | Import local .gguf instead of pulling |
| `systemApps.agentic-nix.backend` | enum, `"ollama"` | `"ollama"` (local, auto-enables ollama) or `"claude-api"` |
| `app.opencode.enable` | bool | Installs opencode via `programs.opencode` |
| `app.opencode.huggingface.enable` | bool | Use HuggingFace router instead of local ollama |
| `app.opencode.huggingface.model` | str | HF model id |
| `app.opencode.huggingface.baseURL` | str | OpenAI-compatible endpoint |

## 5. Enable it on a host

Add `app.<name>.enable = true;` or `systemApps.<name>.enable = true;` to the
relevant host's config under `hosts/<hostname>/` (or `users/<user>/` for
home-manager).

## 6. Validate before applying

Always run `nixos-rebuild build --flake .` and confirm it succeeds before
`switch`. Never skip this step.
