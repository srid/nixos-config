{ writeShellApplication, curl, reader }:

writeShellApplication {
  name = "article-extractor";

  runtimeInputs = [ curl reader ];

  text = ''
    URL="$1"

    # Create unique temp file
    TEMP_HTML=$(mktemp)

    # Download HTML
    curl -s -L "$URL" > "$TEMP_HTML"

    # Extract and output article to stdout
    reader "$TEMP_HTML"

    # Clean up
    rm "$TEMP_HTML"
  '';
}
