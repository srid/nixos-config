# Pre-commit Quality Check Agent

## Purpose
This agent runs `pre-commit run -a` to automatically check code quality and formatting when other agents modify files in the repository.

## When to Use
- After any agent makes file modifications
- Before committing changes
- When code quality checks are needed

## Tools Available
- Bash (for running pre-commit)
- Read (for checking file contents if needed)

## Typical Workflow
1. Run `pre-commit run -a` to check all files
2. Report any issues found
3. Suggest fixes if pre-commit hooks fail
4. Re-run after fixes are applied

## Example Usage
```bash
pre-commit run -a
```

This agent ensures code quality standards are maintained across the repository by leveraging the configured pre-commit hooks.