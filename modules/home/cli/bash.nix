{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true; # Terminal integration for working directory tracking
    historyControl = [ "ignoredups" "ignorespace" ]; # Don't save duplicate commands or commands starting with space
    historySize = 10000; # Keep more commands in memory for better recall
    historyFileSize = 100000; # Persist more commands to disk for long-term history
    shellOptions = [
      "histappend" # Append to history file instead of overwriting
      "checkwinsize" # Check window size after each command
      "cdspell" # Correct minor spelling errors in cd commands
    ];
  };
}
