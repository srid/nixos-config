# Fix broken autocompletion in home-manager zsh.
# See https://github.com/nix-community/home-manager/issues/2562.
# TODO: Remove this after https://github.com/nix-community/home-manager/pull/5458
{
  home-manager.sharedModules = [
    ({ config, ... }: {
      programs.zsh.initExtraBeforeCompInit = ''
        fpath+=("${config.home.profileDirectory}"/share/zsh/site-functions "${config.home.profileDirectory}"/share/zsh/$ZSH_VERSION/functions "${config.home.profileDirectory}"/share/zsh/vendor-completions)
      '';
    })
  ];

  # Even though we enable zsh in home-manager, we still need to enable the
  # nix-darwin module to make completions work.
  programs.zsh.enable = true;
}
