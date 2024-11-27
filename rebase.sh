# Abort if the working directory is dirty or there are untracked files
if ! git diff --quiet; then
    echo "❌ Working directory is dirty. Please commit or stash your changes."
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)

REMOTE_MAIN_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD || (git remote set-head origin --auto && git rev-parse --abbrev-ref origin/HEAD))
MAIN_BRANCH=$(echo $REMOTE_MAIN_BRANCH | sed 's/origin\///')

git checkout $MAIN_BRANCH
git pull
git rebase -i $MAIN_BRANCH $CURRENT_BRANCH

exit 0

