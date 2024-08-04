def main [pr_url: string] {
    let parsed = ($pr_url | parse -r 'https://github\.com/(?P<owner>[\w-]+)/(?P<repo>[\w-]+)/pull/(?P<pr_number>\d+)')
    
    if ($parsed | is-empty) {
        error make {msg: "Failed to parse GitHub URL. Please ensure it's in the correct format."}
    }

    print $"Parsed URL data: ($parsed)"

    let owner = $parsed.owner.0
    let repo = $parsed.repo.0
    let pr_number = $parsed.pr_number.0

    print $"Owner: ($owner)"
    print $"Repo: ($repo)"
    print $"PR Number: ($pr_number)"

    # Construct API URL
    let api_url = $"https://api.github.com/repos/($owner)/($repo)/pulls/($pr_number)"

    print $"Constructed API URL: ($api_url)"
    
    let pr_details = (http get $api_url)
    let branch_name = $pr_details.head.ref
    let clone_url = $pr_details.head.repo.clone_url

    # Create a temporary directory
    let temp_dir = (mktemp -d)
    cd $temp_dir

    # Clone the repository
    git clone $clone_url .
    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Failed to clone repository"}
    }

    # Checkout the PR branch
    git checkout $branch_name
    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Failed to checkout branch"}
    }

    # Force push to the branch
    git commit --amend --no-edit
    git push -f origin $branch_name
    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Failed to force push"}
    }

    print $"Successfully force pushed to ($branch_name)"

    # Clean up
    cd ..
    rm -rf $temp_dir
} 