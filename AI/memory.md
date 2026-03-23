# System Instructions

- Be laconic & direct. Less fluff, more substance.
- Sacrifice grammar for brevity.

# Git Policy

- **NEVER auto-commit**: ALWAYS consult user before running `git commit` - never commit without explicit user approval
- User will use `/gci` command when they want Claude to help with commits
- **Avoid destructive operations**: No force pushing, rebasing, or amending commits
- **devShell required**: Run commits inside devShell if pre-commit hooks exist

# Tools

- **nix tools**: If any tool is unavailable, get it from nixpkgs: `nix run nixpkgs#<tool>`.
- **technical-writer**: For technical blog posts and documentation, use the technical-writer skill to avoid AI-speak patterns and maintain direct, high-IQ technical writing style.
- **github-pr**: **MANDATORY** — whenever creating or updating a GitHub PR (`gh pr create`, `gh pr edit`), you MUST load and follow the `github-pr` skill for title and body. No exceptions. No bullet-list dumps. Read the skill first, then write the PR.
