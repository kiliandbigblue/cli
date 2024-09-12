# Abort if the working directory is dirty or there are untracked files
if ! git diff --quiet; then
    echo "❌ Working directory is dirty. Please commit or stash your changes."
    exit 1
fi

REMOTE_MAIN_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD || (git remote set-head origin --auto && git rev-parse --abbrev-ref origin/HEAD))
MAIN_BRANCH=$(echo $REMOTE_MAIN_BRANCH | sed 's/origin\///')

git checkout $MAIN_BRANCH
git pull

# Delete all merged branches and squash and merged branches
gh poi

# git branch --merged $MAIN_BRANCH | grep -v '^\* ' | xargs -n 1 git branch -d
# git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base $MAIN_BRANCH $branch) && [[ $(git cherry $MAIN_BRANCH $(git commit-tree $(git rev-parse "$branch^{tree}") -p $mergeBase -m _)) == "-"* ]] && git branch -D $branch; done
#
# # Rebase all local branches on top of the main branch, ignoring branches with rebase conflicts.
# # The ignored branches will be left untouched and their name is printed out at the end.
# IGNORED_BRANCHES=()
# branches=$(git branch --format='%(refname:short)' | grep -Ev "(^\*|master|main|dev)")
#
# for branch in $branches; do
#     git checkout "$branch"
#     git pull origin $branch
#     if [ $? -ne 0 ]; then
#         echo "Failed to pull $branch. Skipping..."
#         IGNORED_BRANCHES+=("$branch")
#         continue
#     fi
#     git rebase "$MAIN_BRANCH"
#     if [ $? -ne 0 ]; then
#         echo "Rebase conflict in $branch. Skipping..."
#         git rebase --abort
#         IGNORED_BRANCHES+=("$branch")
#     fi
# done
#
# if [ ${#IGNORED_BRANCHES[@]} -eq 0 ]; then
#     echo "All branches were rebased successfully."
# else
#     echo "All branches were rebased except the following branches: ${IGNORED_BRANCHES[@]}"
# fi
#
# git checkout $MAIN_BRANCH

exit 0

