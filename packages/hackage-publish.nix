{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "hackage-publish";
  runtimeInputs = [ pkgs.cat-agenix-secret ];
  meta.description = "Publish Haskell library to Hackage with encrypted password";
  text = ''
    set -e
    
    # Check if we're in a Haskell project
    if [ ! -f "*.cabal" ] && [ ! -f "cabal.project" ]; then
      echo "Error: Not in a Haskell project directory (no .cabal file found)" >&2
      exit 1
    fi
    
    # Parse command line arguments
    dry_run=false
    if [ "$#" -gt 0 ] && [ "$1" = "--dry-run" ]; then
      dry_run=true
      echo "Running in dry-run mode (will print commands instead of executing)"
    fi
    
    # Set cabal command based on dry-run mode
    if [ "$dry_run" = true ]; then
      cabal_cmd="echo cabal"
    else
      cabal_cmd="cabal"
    fi
    
    echo "Step 2: Generating distribution tarball..."
    $cabal_cmd sdist
    
    echo "Step 3: Getting Hackage password..."
    if [ "$dry_run" = true ]; then
      password="<HACKAGE_PASSWORD>"
    else
      password=$(cat-agenix-secret hackage-password.age)
      if [ -z "$password" ]; then
        echo "Error: Failed to get Hackage password" >&2
        exit 1
      fi
    fi
    
    echo "Step 4: Uploading to Hackage..."
    read -p "Upload package to Hackage? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      $cabal_cmd upload -u sridca -P "$password" --publish
    else
      echo "Upload cancelled"
      exit 0
    fi
    
    echo "Step 5: Uploading documentation..."
    $cabal_cmd upload -d -u sridca -P "$password" --publish
    
    echo "Hackage publish completed successfully!"
  '';
}
