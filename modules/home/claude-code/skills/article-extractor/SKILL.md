---
name: article-extractor
description: Extract clean article content from URLs using reader. Use when user wants to download/extract/save an article from a URL.
allowed-tools:
  - Bash
  - Write
---

# Article Extractor

Extracts clean article content from URLs using `reader` (Mozilla Readability).

## When to Use

User wants to:
- Extract article from URL
- Download blog post content
- Save article as text

## Workflow

```bash
# Download HTML
curl -L "$URL" > temp.html

# Extract article
reader temp.html > temp.txt

# Get title from first line
TITLE=$(head -n 1 temp.txt | sed 's/^# //')

# Clean filename
FILENAME=$(echo "$TITLE" | tr '/:?"<>|' '-' | cut -c 1-80 | sed 's/ *$//')".txt"

# Save
mv temp.txt "$FILENAME"

# Clean up
rm temp.html

# Show preview
echo "✓ Saved: $FILENAME"
head -n 10 "$FILENAME"
```

