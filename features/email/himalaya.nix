{ pkgs, system, inputs, ... }:
let
  himalaya = inputs.himalaya.outputs.defaultPackage.${system};
in
# Wrap himalaya to be aware of ProtonMail's bridge cert.
pkgs.writeScriptBin "himalaya" ''
  #!${pkgs.stdenv.shell}
  export SSL_CERT_FILE=~/.config/protonmail/bridge/cert.pem
  exec ${himalaya}/bin/himalaya $*
''
