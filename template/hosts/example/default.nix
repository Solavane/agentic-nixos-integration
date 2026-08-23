{ ... }:
{
  users.users.example = {
    isNormalUser = true;
    initialPassword = "password";
  };
  systemApps.agentic-nix.enable = true;
}
