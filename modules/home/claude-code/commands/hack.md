---
name: hack
description: Implement a GitHub issue end-to-end until CI passes
args:
  - name: issue_url
    description: GitHub issue URL (e.g., https://github.com/user/repo/issues/123)
    required: true
  - name: plan_mode
    description: Whether to run in plan mode (true/false, default false)
    required: false
---

This command implements a GitHub issue from start to finish, ensuring all CI checks pass.

**Usage**: `/hack <github-issue-url> [plan_mode]`

**What it does**:
1. Fetches the GitHub issue details using `gh` CLI
2. Analyzes the issue requirements and creates an implementation plan
3. If plan_mode=true, presents plan for approval before implementing
4. Implements the requested feature or fix
5. Creates a commit with proper issue reference
6. Runs `om ci` to validate the implementation
7. Iterates and fixes any CI failures until all checks pass

**Workflow**:
1. Parse the GitHub issue URL to extract repository and issue number
2. Use `gh api` to fetch issue title, description, and labels
3. Create a detailed implementation plan based on issue requirements
4. Implement the solution step by step
5. Commit changes with concise description
6. Run `om ci` and analyze any failures
7. Fix CI issues and re-run until all checks pass
8. Provide final status report

**Prerequisites**:
- GitHub CLI (`gh`) must be authenticated
- Must be in a git repository with a non-mainline branch
- omnix (`om`) must be available for CI checks
- Repository must have CI configured via omnix

**Error handling**:
- Validates GitHub URL format
- Handles GitHub API errors gracefully
- Provides detailed feedback on CI failures
- Supports iterative fixing until CI passes

**Examples**:
```
/hack https://github.com/myorg/myproject/issues/42
/hack https://github.com/myorg/myproject/issues/42 true
```

First example directly implements issue #42. Second example creates a plan first and waits for approval before implementing.