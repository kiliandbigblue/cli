CURRENT_BRANCH=$(git branch --show-current)

git push -f origin $CURRENT_BRANCH

# Check if a PR already exists for the current branch
PR_URL=$(gh pr view --json url --jq '.url' --state open --base main --head $CURRENT_BRANCH 2>/dev/null)
if [ -n "$PR_URL" ]; then
    gh pr view --web
else 
    gh pr create --title $CURRENT_BRANCH --web -a @me
fi

exit 0

