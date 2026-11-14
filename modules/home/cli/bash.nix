{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # Atuin records every command in its own database, and its widgets own
    # up-arrow and Ctrl-R (fzf's history widget is disabled in terminal.nix).
    # Bash's history file is then a second, unfiltered copy: commands Atuin's
    # `history_filter` drops (API_KEY=..., TOKEN=...) still get written to
    # ~/.bash_history in plain text. Keep the in-memory list so `!!`, `!$` and
    # `history` still work, but persist nothing.
    historyFile = "/dev/null";
    historyFileSize = null;
    historyControl = [ "ignoredups" "ignorespace" ]; # Don't save duplicate commands or commands starting with space
    historySize = 10000; # Keep more commands in memory for better recall
    shellOptions = [
      "checkwinsize" # Check window size after each command
      "cdspell" # Correct minor spelling errors in cd commands
    ];
  };
}
