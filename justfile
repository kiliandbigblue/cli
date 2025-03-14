[private]
@default:
    just --list

# Fetch all remotes
[no-cd]
[private]
@fetch-all:
  git fetch --all
  echo "Successfully fetched all"

# Deploy a reflow or atlas service interactively 
[group('devops')]
[no-cd]
deploy: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/deploy.sh

# Open the logs of a reflow or atlas service interactively 
[group('devops')]
[no-cd]
logs: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/logs.sh


# Create a new branch and commit the selected changes
[group('git')]
[no-cd]
create: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/create.sh
  
# Amend the selected changes to the current commit
[group('git')]
[no-cd]
modify: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/modify.sh

# Submit a pull request with the current branch
[group('git')]
[no-cd]
submit: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/submit.sh

# Sync the current repo with the remote one.
[group('git')]
[no-cd]
sync: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/sync.sh

# Rebase the current branch on top of the main branch
[group('git')]
[no-cd]
rebase: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/rebase.sh

# Create a new branch, commit the selected changes, rebase on top of the main branch then submit it
[group('git')]
[no-cd]
pr: fetch-all create rebase submit

# Tag the current revision with a increasing -fix.X number
[group('git')]
[no-cd]
tag: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/tag.sh
