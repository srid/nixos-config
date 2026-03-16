---
description: Apply preferred GitHub repo settings
subtask: true
---

# GH Settings Command

Apply preferred GitHub repository settings.

## Usage

```
/gh-settings              # Apply to current repo
/gh-settings owner/repo   # Apply to specific repo
```

## Settings Applied

1. **Squash merge format**: title=PR_TITLE, message=PR_BODY
2. **Disable**: wiki, projects, merge-commit
3. **Enable**: rebase-merge, squash-merge
4. **Enable**: allow-update-branch, delete-branch-on-merge

## Workflow

1. **Detect Repository**
   - If argument provided: use `owner/repo` format
   - If no argument: detect from `git remote get-url origin`
     ```bash
     git remote get-url origin | sed 's/.*github.com[/:]//' | sed 's/.git$//'
     ```

2. **Apply Settings**
   
   Run both commands:
   ```bash
   # Set squash merge commit format
   gh api --method PATCH repos/{owner}/{repo} -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY > /dev/null
   
   # Apply repository settings
   gh repo edit --enable-wiki=false --enable-projects=false --enable-merge-commit=false --enable-rebase-merge --enable-squash-merge --allow-update-branch --delete-branch-on-merge
   ```

3. **Confirm**
   - Report success to user
   - Show the repo that was updated

## Requirements

- `gh` CLI installed and authenticated (use `nix run nixpkgs#gh` if not installed)
- Must have admin access to the repository
- Repository must have a GitHub remote (for auto-detection)

## Notes

- This is idempotent - running multiple times has the same effect
- Settings are applied in sequence; both must succeed for complete application
- The `{owner}/{repo}` placeholder in the API call works with `gh` CLI's default behavior
