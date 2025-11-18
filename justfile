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
deploy:
  #!/usr/bin/env sh
  ~/projects/cli/deploy.sh

# Open the logs of a reflow or atlas service interactively 
[group('devops')]
[no-cd]
logs:
  #!/usr/bin/env sh
  ~/projects/cli/logs.sh

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

# Tag the current revision with a increasing -fix.X number
[group('git')]
[no-cd]
tag: fetch-all
  #!/usr/bin/env sh
  ~/projects/cli/tag.sh
