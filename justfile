
[private]
@default:
    just --list

# Fetch all remotes
[no-cd]
[private]
@fetch-all:
  git fetch --all

# Deploy a reflow or atlas service interactively 
[no-cd]
deploy: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/deploy.sh

# Create a new branch and commit the selected changes
[no-cd]
create $MODE='-i': fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/create.sh
  
# Amend the selected changes to the current commit
[no-cd]
modify $MODE='-i': fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/modify.sh

# Submit a pull request with the current branch
[no-cd]
submit $MODE='': fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/submit.sh
