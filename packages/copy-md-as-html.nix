{ writeShellApplication, wl-clipboard, pandoc, ... }:

writeShellApplication {
  name = "copy-md-as-html";
  meta.description = ''
    Convert the given Markdown to HTML (using pandoc) and copy it to the clipboard.

    This is useful for pasting Markdown content into rich text editors or GUI email clients (like Gmail).
  '';
  runtimeInputs = [ wl-clipboard pandoc ];
  text = ''
    set -x
    pandoc "$1" -t html | wl-copy -t text/html
    echo "Copied HTML to clipboard"
  '';
}
