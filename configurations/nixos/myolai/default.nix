# Dropbox + olai in an incus container on naiveintent. The outliner is
# reachable only at https://myolai.<tailnet>.ts.net — olai binds
# loopback and `tailscale serve` is the only way in.
#
# Lifecycle (`just incus <cmd> myolai`): modules/nixos/linux/incus/README.md.
# One-time Dropbox account link after the first deploy: the daemon logs a
# https://www.dropbox.com/cli_link_nonce=… URL — from `just incus shell
# myolai`, grab it with
#   journalctl _SYSTEMD_USER_UNIT=dropbox.service | grep dropbox.com
# and open it in a browser.
{ config, flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  username = flake.config.me.username;
  home = config.users.users.${username}.home;

  # The mail row wants its two values as environment variables
  # (OLAI_MAIL_OAUTH_CLIENT / OLAI_MAIL_OAUTH_SECRET, juspay/olai#607) and the
  # only material this container holds is the client_secret JSON Google hands
  # out, so the two are read out of it here. A Web-application client is the
  # only kind that can carry this serve's redirect URI, so `.web` is the whole
  # of the input, and anything unreadable leaves the doors unset — which is a
  # state the row names in its own words — rather than writing a value that is
  # not there.
  mailEnv = pkgs.writeShellScript "olai-mail-env" ''
    set -euo pipefail
    json=$1 out=$2 user=$3 group=$4
    client=""
    secret=""
    if [ -r "$json" ]; then
      client=$(${pkgs.jq}/bin/jq -r '.web.client_id // empty' "$json" 2>/dev/null) || client=""
      secret=$(${pkgs.jq}/bin/jq -r '.web.client_secret // empty' "$json" 2>/dev/null) || secret=""
    fi
    # Lengths, never values: activation output is what a failed deploy shows.
    echo "olai-mail-env: $json $([ -r "$json" ] && echo readable || echo MISSING), client ''${#client} chars, secret ''${#secret} chars -> $out" >&2
    install -d -m 700 -o "$user" -g "$group" "$(dirname "$out")"
    (umask 077 && printf 'OLAI_MAIL_OAUTH_CLIENT=%s\nOLAI_MAIL_OAUTH_SECRET=%s\n' "$client" "$secret" > "$out")
    chown "$user:$group" "$out"
    chmod 400 "$out"
  '';
in
{
  imports = [
    (self + /modules/nixos/linux/incus/guest.nix)
    # Secrets for this container decrypt as root with its own ssh host key
    # (/etc/ssh/ssh_host_ed25519_key — agenix's default identityPaths).
    inputs.agenix.nixosModules.default
  ];

  # The mail row's Gmail OAuth client (juspay/olai#607). agenix hands the
  # plaintext to the user olai runs as.
  age.secrets."olai-mail-oauth-client.json" = {
    file = self + /secrets/olai-mail-oauth-client.json.age;
    owner = username;
  };

  # ...and its two values are derived in the same pass, into the file olai names
  # as its EnvironmentFile. This has to happen here rather than from the olai
  # unit: systemd refuses to start a unit whose EnvironmentFile is missing, so
  # no ExecStartPre of that unit can be what creates it. Activation runs before
  # any service, at every switch and every boot.
  system.activationScripts.olai-mail-env = {
    deps = [ "agenix" ];
    text = ''
      ${mailEnv} ${config.age.secrets."olai-mail-oauth-client.json".path} \
        ${home}/.config/agenix/olai-mail.env ${username} ${config.users.users.${username}.group}
    '';
  };

  networking.hostName = "myolai";
  nixpkgs.hostPlatform = "x86_64-linux"; # runs on naiveintent
  nixpkgs.config.allowUnfree = true; # dropbox

  # Publish olai's (loopback-bound) port on the tailnet.
  incus.servePort = config.home-manager.users.${username}.services.olai.port;

  # Claude Code's native installer (claude.ai/install.sh) downloads a
  # dynamically-linked binary; give it the standard ELF loader path.
  programs.nix-ld.enable = true;

  users.users.${username} = {
    isNormalUser = true;
    # dropbox and olai are home-manager user services; they must start
    # at boot without a login session.
    linger = true;
  };

  # Activation refuses to clobber files it didn't create (lazygit writes a
  # default ~/.config/lazygit/config.yml on first run); move them aside.
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.${username} = {
    imports = [
      # Dropbox disabled for now; olai runs against a local (unsynced)
      # dataDir until this comes back.
      # (self + /modules/home/services/dropbox.nix)
      # git + delta + lazygit, configured as on the other hosts.
      (self + /modules/home/cli/git.nix)
      (self + /modules/home/cli/just.nix)
      (self + /modules/home/editors/neovim)
      ./olai.nix
    ];
    home.packages = [ pkgs.uv pkgs.python3 ];
    home.stateVersion = "25.11";
  };

  system.stateVersion = "25.11";
}
