# Contributing to agentic-nixos-integration core

This repo provides `lib.mkApp` / `lib.mkSystemApp`, generic modules, and a
scaffold template. It has no knowledge of any specific person's config —
don't add anything here that's only useful to one setup; that belongs in the
consumer's own `modules/`.

## Adding a module to core
Only add modules here if they're genuinely generic (e.g. git, common CLI
tools) — anything opinionated or personal belongs in the person's own config,
not core.

Follow the same `mkApp`/`mkSystemApp` convention as `template/AGENTS.md`
describes for consumers — core's own modules should look identical in shape
to what an end user would write.

## Changing mkApp / mkSystemApp
These are consumed by every downstream config via `nix-core.lib.*`. Treat
signature changes (renaming params, changing defaults) as breaking — bump
something noticeable (a comment, a CHANGELOG entry) so consumers notice on
their next `nix flake update`.
