# A rough flake-parts module for activating the system
#
# TODO: Replace with deploy-rs or (new) nixinate
{ self, inputs, ... }:
{
  perSystem = { system, pkgs, lib, ... }: {
    apps.default =
      let
        # Create a flake app that wraps the given bash CLI.
        bashCmdApp = name: cmd: {
          type = "app";
          program =
            (pkgs.writeShellApplication {
              inherit name;
              text = ''
                set -x
                ${cmd}
              '';
            }) + "/bin/${name}";
        };
      in
      if system == "aarch64-darwin" then
        bashCmdApp "darwin" ''
          ${self.darwinConfigurations.default.system}/sw/bin/darwin-rebuild \
            switch --flake ${self}#default
        ''
      else
        bashCmdApp "linux" ''
          ${lib.getExe pkgs.nixos-rebuild} --use-remote-sudo switch -j auto
        '';
  };
}
