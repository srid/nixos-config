{ pkgs, lib, ... }: {
  environment.systemPackages =
    let
      # FIXME: This leads to forbidden error
      # himalaya = toString inputs.himalaya.defaultApp."${system}".program;
      # Wrap himalaya to be aware of ProtonMail's bridge cert.
      himalayaWithSslEnv =
        pkgs.writeScriptBin "h" ''
          #!${pkgs.stdenv.shell}
          export SSL_CERT_FILE=~/.config/protonmail/bridge/cert.pem
          exec nix run github:srid/himalaya/nixify $*
        '';
    in
    [
      himalayaWithSslEnv
    ];
}
