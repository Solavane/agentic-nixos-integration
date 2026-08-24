# users/example/home.nix
#
# The home-manager side of the example user. This file documents every
# option that agentic-nixos-integration introduces per user (the
# `app.*` namespace) — same idea as hosts/example/default.nix, just one
# scope down.
#
# Scope rules of thumb:
#   * `app.<name>.enable`   — this program for this user only.
#   * `systemApps.<name>.enable` — system-wide service/daemon; lives in
#     the host config instead.

{ ... }:

{
  # --- Housekeeping ---------------------------------------------------
  # The release this home configuration was first generated for. It does
  # NOT track your nixpkgs channel: leave it at its initial value
  # forever, even while updating everything else, or Home Manager will
  # refuse to evaluate.
  home.stateVersion = "26.11";

  # ==================================================================
  # opencode — the AI coding agent used by agentic-nix
  # ==================================================================
  # Enabling this installs opencode and turns on its upstream
  # home-manager module (`programs.opencode.enable`). On top of that,
  # the module wires a model provider for you. Two mutually exclusive
  # sources, evaluated in this order:
  #
  #   1. HuggingFace, if you set huggingface.enable = true;
  #   2. otherwise the local ollama service, if the host it runs on has
  #      systemApps.ollama enabled.
  #
  # In case 2 nothing here needs configuring: the provider is pointed
  # at http://127.0.0.1:11434/v1 and the model name is read from the
  # host's `systemApps.ollama.model`, so the ollama block in the host
  # config remains the single place to change models.
  app.opencode = {
    enable = true;

    # --- Alternative backend: HuggingFace ----------------------------
    # Route requests through HuggingFace's Inference Providers router
    # instead of local inference. Useful on machines without a GPU.
    #
    # Needs a HUGGINGFACE_API_KEY in the environment (e.g. exported in
    # your shell or managed by a secrets tool) — the config below only
    # references it via {env:HUGGINGFACE_API_KEY}.
    huggingface = {
      enable = false;

      # Model id passed to the router verbatim. Any text-generation
      # model served by Inference Providers works.
      model = "meta-llama/Llama-3.3-70B-Instruct";

      # OpenAI-compatible endpoint. Only change this if you route
      # through a proxy or mirror.
      baseURL = "https://router.huggingface.co/v1";
    };
  };
}
