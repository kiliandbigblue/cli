#!/bin/bash

# Exit on error
set -e

# Function to normalize version to vX.Y.Z format
normalize_version() {
    local version=$1
    # Extract vX.Y.Z part using regex
    if [[ $version =~ ^(v[0-9]+\.[0-9]+\.[0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo "Error: Invalid version format" >&2
        exit 1
    fi
}

# Function to get next fix number
get_next_fix_number() {
    local base_version=$1
    local max_fix=0
    
    # Look for existing fix tags
    while read -r tag; do
        if [[ $tag =~ ${base_version}-fix\.([0-9]+)$ ]]; then
            fix_num="${BASH_REMATCH[1]}"
            if (( fix_num > max_fix )); then
                max_fix=$fix_num
            fi
        fi
    done < <(git tag -l "${base_version}-fix.*")
    
    echo $((max_fix + 1))
}

# Get the latest tag by creation date
latest_tag=$(git for-each-ref --sort=-creatordate --format '%(refname:short)' refs/tags --count=1)

if [ -z "$latest_tag" ]; then
    echo "Error: No tags found in repository" >&2
    exit 1
fi

# Normalize the version
base_version=$(normalize_version "$latest_tag")
if [ $? -ne 0 ]; then
    exit 1
fi

# Get next fix number
next_fix=$(get_next_fix_number "$base_version")

# Create new tag name
new_tag="${base_version}-fix.${next_fix}"

echo "Creating new tag: $new_tag"

git tag $new_tag && git push origin $new_tag


