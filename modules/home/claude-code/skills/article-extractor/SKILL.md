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
```

