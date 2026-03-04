{ config, pkgs, lib, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      # Until https://github.com/nix-community/home-manager/pull/5773
      package = lib.mkIf (config.nix.package != null)
        (pkgs.nix-direnv.override { nix = config.nix.package; });
    };
    config.global = {
      hide_env_diff = true;
    };
  };

  # Avoid "warning: unhandled Platform key FamilyDisplayName" which crashes lazygit
  # See: https://github.com/jesseduffield/lazygit/issues/5279
  # We use a file in lib/ that sorts alphabetically after hm-nix-direnv.sh
  # so that we can wrap its functions.
  xdg.configFile."direnv/lib/zz-macos-fix.sh".text = ''
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # Wrap use_flake
      if declare -f use_flake >/dev/null; then
        eval "$(declare -f use_flake | sed 's/^use_flake/original_use_flake/')"
        use_flake() { original_use_flake "$@"; unset DEVELOPER_DIR; }
      fi
      # Wrap use_nix
      if declare -f use_nix >/dev/null; then
        eval "$(declare -f use_nix | sed 's/^use_nix/original_use_nix/')"
        use_nix() { original_use_nix "$@"; unset DEVELOPER_DIR; }
      fi
    fi
  '';
}
