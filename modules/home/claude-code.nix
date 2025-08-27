{ flake, pkgs, ... }:
{
  programs.claude-code = {
    enable = true;

    package = flake.inputs.vertex.packages.${pkgs.system}.default;

    # Basic settings for Claude Code
    settings = {
      enableAllProjectMcpServers = true;
      permissions = {
        defaultMode = "plan";
        allow = [
          "Bash(nix develop:*)"
          "Bash(nix build:*)"
          "Bash(om ci)"
          "Bash(rg:*)"
        ];
      };
    };

    # Custom commands can be added here
    commands = {
      "om-ci" = ''
        #!/bin/bash
        # Run local CI (Nix)
        om ci
      '';
    };

    # Custom agents can be added here
    agents = {
      "pre-commit" = ''
        ---
        name: pre-commit
        description: Invoke after changing sources locally, and only if git-hooks.nix is used by Nix.
        tools: pre-commit
        ---
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
      '';
    };

    # MCP servers configuration
    mcpServers = {
      "nixos-mcp" = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
    };
  };
}
