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

Extract article content and save it:

```bash
CONTENT=$(@article-extractor@ "$URL")
```

Then use the Write tool to save `$CONTENT` to the desired location with an appropriate filename.

The script outputs clean markdown content to stdout. You decide where and how to save it based on the user's request.

