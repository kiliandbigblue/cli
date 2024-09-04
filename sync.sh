# Abort if the working directory is dirty or there are untracked files
if ! git diff --quiet; then
    echo "❌ Working directory is dirty. Please commit or stash your changes."
    exit 1
fi

REMOTE_MAIN_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD || (git remote set-head origin --auto && git rev-parse --abbrev-ref origin/HEAD))
MAIN_BRANCH=$(echo $REMOTE_MAIN_BRANCH | sed 's/origin\///')

git checkout $MAIN_BRANCH
git pull

# Delete all merged branches
git branch --merged | grep -Ev "(^\*|master|main|dev)" | xargs git branch -d

# Rebase all local branches on top of the main branch, ignoring branches with rebase conflicts
git branch --format='%(refname:short)' | grep -v "$MAIN_BRANCH" | while read branch; do
    git checkout $branch
    git rebase $MAIN_BRANCH
    if [ $? -ne 0 ]; then
        echo "Rebase conflict in $branch. Skipping..."
        git rebase --abort
    fi
done

