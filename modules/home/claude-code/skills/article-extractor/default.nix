{ writeShellApplication, curl, reader }:

# Inspired by https://github.com/michalparkola/tapestry-skills-for-claude-code/blob/main/article-extractor/SKILL.md
writeShellApplication {
  name = "article-extractor";

  runtimeInputs = [ curl reader ];

  text = ''
    URL="$1"

    # Download HTML
    curl -L "$URL" > /tmp/temp.html

    # Extract article
    reader /tmp/temp.html > /tmp/temp.txt

    # Get title from first line
    TITLE=$(head -n 1 /tmp/temp.txt | sed 's/^# //')

    # Clean filename
    FILENAME=$(echo "$TITLE" | tr '/:?"<>| ' '-' | cut -c 1-80 | sed 's/-*$//')".txt"

    # Save
    mv /tmp/temp.txt "/tmp/$FILENAME"

    # Clean up
    rm /tmp/temp.html

    # Show preview
    echo "✓ Saved: /tmp/$FILENAME"
    head -n 10 "/tmp/$FILENAME"
  '';
}
