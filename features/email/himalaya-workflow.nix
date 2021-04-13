{ pkgs, lib, system, inputs, ... }:
{
  environment.systemPackages =
    let
      himalaya = import ./himalaya.nix { inherit pkgs system inputs; };
      # Helper to read and display the (HTML) email message in Markdown,
      # highlighted with pager.
      himalayaReadMail =
        pkgs.writeScriptBin "h-read" ''
          #!${pkgs.stdenv.shell}
          ${himalaya}/bin/himalaya read $* \
            | ${pkgs.pandoc}/bin/pandoc -f html -t markdown_strict \
            | ${pkgs.bat}/bin/bat -l md
        '';
      # TODO more helpers
      # - `h move` with fzf-selector for target folder
    in
    [
      himalaya
      # Helpers
      himalayaReadMail
    ];
}
