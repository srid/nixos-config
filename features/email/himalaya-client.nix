{ pkgs, lib, system, inputs, ... }:
let
  himalaya = inputs.himalaya.outputs.defaultPackage.${system};
in
{
  environment.systemPackages =
    let
      # Wrap himalaya to be aware of ProtonMail's bridge cert.
      himalayaWithSslEnv =
        pkgs.writeScriptBin "h" ''
          #!${pkgs.stdenv.shell}
          export SSL_CERT_FILE=~/.config/protonmail/bridge/cert.pem
          exec ${himalaya}/bin/himalaya $*
        '';
      # Helper to read and display the (HTML) email message in Markdown,
      # highlighted with pager.
      himalayaReadMail =
        pkgs.writeScriptBin "h-read" ''
          #!${pkgs.stdenv.shell}
          ${himalayaWithSslEnv}/bin/h read $* \
            | ${pkgs.pandoc}/bin/pandoc -f html -t markdown_strict \
            | ${pkgs.bat}/bin/bat -l md
        '';
      # TODO more helpers
      # - `h move` with fzf-selector for target folder
    in
    [
      himalayaWithSslEnv
      # Helpers
      himalayaReadMail
    ];
}
