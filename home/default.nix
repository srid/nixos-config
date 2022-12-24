{ self, inputs, config, ... }:
{
  flake = {
    homeModules = {
      common = {
        home.stateVersion = "22.11";
        imports = [
          ./tmux.nix
          ./neovim.nix
          ./emacs.nix
          ./starship.nix
          ./terminal.nix
          ./direnv.nix
        ];
      };
      common-linux = {
        imports = [
          self.homeModules.common
          ./vscode-server.nix
        ];
        programs.bash.enable = true;
      };
      common-darwin = {
        imports = [
          self.homeModules.common
        ];

        programs.zsh.enable = true;
        # To put nix and home-manager-installed packages in PATH.
        # TODO: Use sessionPath after https://github.com/nix-community/home-manager/issues/3324
        programs.zsh.initExtra = ''
          export PATH=/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin/:$PATH
          # For 1Password CLI. This requires `pkgs.gh` to be installed.
          source $HOME/.config/op/plugins.sh
        '';
      };
    };
  };
}
