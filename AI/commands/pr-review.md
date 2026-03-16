---
description: Resolve PR review comments
subtask: true
---

# PR Review Command

Fetch and resolve review comments from a GitHub pull request by implementing the requested changes.

## Usage

```
/pr-review                    # Review comments on current branch's PR
/pr-review 123                # Review comments on PR #123
/pr-review https://github.com/owner/repo/pull/123
```

## Workflow

### 1. **Identify the PR**

   - If URL provided: Extract owner, repo, and PR number
   - If number provided: Use current repo (from `git remote -v`)
   - If no argument: Get PR number from current branch using `gh pr view --json number`

### 2. **Fetch Review Comments**

   **IMPORTANT: Fetch REVIEW COMMENTS, not plain comments. Review comments are on specific lines of code.**

   Use `gh api` to fetch:
   ```bash
   # Get PR review threads (includes is_resolved field)
   gh api repos/OWNER/REPO/pulls/NUMBER/threads
   
   # Get PR reviews (contains review state: CHANGES_REQUESTED, APPROVED, etc.)
   gh api repos/OWNER/REPO/pulls/NUMBER/reviews
   ```
   
   **IMPORTANT: Filter out resolved threads. Only process threads where `is_resolved` is false.**
   
   The threads API returns:
   - `is_resolved`: Whether the thread has been marked as resolved
   - `path`: File being commented on
   - `line`: Line number
   - `comments`: Array of comments in the thread
     - `body`: Comment text
     - `user.login`: Author
   - `pull_request_review_id`: Links to the review

### 3. **Filter and Present Comments**

   - **Filter out resolved threads** - only process threads where `is_resolved` is false
   - Group threads by file for clarity
   - Check review states - prioritize comments from reviews with `CHANGES_REQUESTED` state
   - Present a summary:
     ```markdown
     ## PR #123 Review Comments
     
     ### src/auth.rs (2 comments)
     1. @reviewer: "This function should handle the error case properly"
        Line: 45
     2. @reviewer: "Consider using a constant here"
        Line: 52
     
     ### src/main.rs (1 comment)
     1. @reviewer: "Add documentation"
        Line: 12
     
     Total: 3 unresolved comments
     ```

### 4. **Implement Changes**

   For each review comment:
   - Read the relevant file and understand the context around the commented line
   - Implement the requested change
   - Use the comment's intent, not just literal interpretation
   - If a comment is unclear, ask for clarification before proceeding
   - After making changes, confirm with the user

### 5. **Summary**

   After implementing all changes:
   - List what was changed in response to each comment
   - Remind user to push changes and respond to comments on GitHub
   - Optionally: `git diff --stat` to show changed files

## API Details

### Fetching Review Comments

```bash
# Get the repo from git remote
REPO=$(git remote get-url origin | sed 's/.*github.com[/:]//' | sed 's/.git$//')

# Fetch review comments
gh api "repos/$REPO/pulls/$NUMBER/comments" --jq '.[] | select(.in_reply_to_id == null) | {path, line, body, user: .user.login}'

# Fetch reviews to see states
gh api "repos/$REPO/pulls/$NUMBER/reviews" --jq '.[] | {user: .user.login, state, body}'
```

### Comment vs Review Comment

- **Issue comments** (`/issues/123/comments`): General discussion, not tied to code
- **Review comments** (`/pulls/123/comments`): Tied to specific lines of code during review
- This command handles **review comments only**

## Requirements

- `gh` CLI installed and authenticated (use `nix run nixpkgs#gh` if not installed)
- Repository must have a GitHub remote
- For no-argument usage: current branch must have an associated PR

## Notes

- Focus on actionable code comments, not general discussion
- If review was dismissed, still show the comments for context
- If multiple reviews exist, show comments from all but prioritize unresolved ones
- After implementing, the user should mark conversations as resolved on GitHub
