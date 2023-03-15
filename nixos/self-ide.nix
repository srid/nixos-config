{ pkgs, flake, ... }: {
  # For no-prompt Ctrl+Shift+B in VSCode
  security.sudo.extraRules = [
    {
      users = [ flake.config.people.myself ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
