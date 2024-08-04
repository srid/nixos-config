{ nuenv, curl, jq, ... }:

nuenv.writeShellApplication {
  name = "touchpr";
  runtimeInputs = [ curl jq ];
  meta.description = ''
    Force push to a PR so as to trigger GitHub Actions
  '';
  text = ''
    #!/usr/bin/env nu

    ${builtins.readFile ./touchpr.nu} 
  '';
}
