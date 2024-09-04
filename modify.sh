MODE=$(gum choose "All" "Interactive")
if [ "$MODE" = "Interactive" ]; then
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

git commit --amend --no-edit

exit 0

