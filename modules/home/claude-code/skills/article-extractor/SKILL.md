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
@article-extractor@ "$URL"
```

