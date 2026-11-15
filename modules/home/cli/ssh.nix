# `just activate [host]` exports NIX_CONFIG when `oss_cache=1`, and remote
# activations must get it too. Only variables named in SendEnv cross ssh, and
# nixos-unified runs its own `ssh` (as does `nix copy`), so this belongs in
# ssh_config rather than on one command line. The receiving host accepts it in
# `modules/nixos/shared/forward-nix-config.nix`.
#
# `enable` is what renders ~/.ssh/config at all: `settings` alone does nothing
# (pureintent imported controlpersist.nix but had no ssh config, so its
# ControlMaster settings were dormant).
{
  programs.ssh = {
    enable = true;
    settings."*" = {
      SendEnv = "NIX_CONFIG";
    };
  };
}
