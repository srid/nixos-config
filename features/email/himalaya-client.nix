{ pkgs, lib, ... }: {
  environment.systemPackages =
    let
      # Wrap himalaya to be aware of ProtonMail's bridge cert.
      himalayaWithSslEnv =
        pkgs.writeScriptBin "h" ''
          #!${pkgs.stdenv.shell}
          export SSL_CERT_FILE=~/.config/protonmail/bridge/cert.pem
          # HACK: See note in flake.nix
          exec himalaya $*
        '';
    in
    [
      himalayaWithSslEnv
    ];
}
