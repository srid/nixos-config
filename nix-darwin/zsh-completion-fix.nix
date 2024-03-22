# Fix broken autocompletion. See https://github.com/nix-community/home-manager/issues/2562.
{ flake, ... }:

{
  home-manager.users.${flake.config.people.myself}.imports = [
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
