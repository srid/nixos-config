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
        # This must be envExtra (rather than initExtra), because doom-emacs requires it
        # https://github.com/doomemacs/doomemacs/issues/687#issuecomment-409889275
        #
        # But also see: 'doom env', which is what works.
        programs.zsh.envExtra = ''
          export PATH=/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin/:$PATH
          # For 1Password CLI. This requires `pkgs.gh` to be installed.
          source $HOME/.config/op/plugins.sh
        '';
      };
    };
  };
}
