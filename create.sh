TYPE=$(gum choose --header "Choose branch type:" "fix" "feature" "chore")
NAME=$(gum input --placeholder "> Branch name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
BRANCH_NAME=$TYPE/$NAME

if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
  # Branch exists
  echo "Branch $BRANCH_NAME already exists on remote"
  exit 1
fi

echo "Preparing new branch: $BRANCH_NAME"

MODE=$(gum choose --header "Choose staging mode" "all" "interactive")
if [ "$MODE" = "interactive" ]; then
    # Look for untracked files
    git status -s | grep -q '^??' && {
       gum confirm "Untracked files found. Do you want to add them to the commit?" && git add $(git status -s | grep '^??' | cut -c4-) || echo "Untracked files not added to the commit"
   }
   # Look for unstaged changes
    git status -s | grep -q '^ M' && {
         git add -p .
    }

else
    git add .
fi

# Check that the staging area is not empty
if git diff --cached --quiet; then
    echo "No changes to commit"
    exit 0
fi

echo "Creating branch $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"
git commit -m "$BRANCH_NAME"

exit 0

