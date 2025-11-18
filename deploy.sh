#!/bin/bash

DEFAULT_REFLOW_REPO_PATH=~/projects/reflow
DEFAULT_ATLAS_REPO_PATH=~/projects/atlas
DEFAULT_VOYAGER_REPO_PATH=~/projects/voyager
# Use the default path or read from ENV variables
INTERNAL_REFLOW_REPO_PATH=${REFLOW_REPO_PATH:-$DEFAULT_REFLOW_REPO_PATH}
INTERNAL_ATLAS_REPO_PATH=${ATLAS_REPO_PATH:-$DEFAULT_ATLAS_REPO_PATH}
INTERNAL_VOYAGER_REPO_PATH=${VOYAGER_REPO_PATH:-$DEFAULT_VOYAGER_REPO_PATH}

# Prompt for repository selection
REPO_NAME=$(gum choose --header "Choose repository" reflow atlas voyager)
TITLE=$(echo "$REPO_NAME" | tr '[a-z]' '[A-Z]')

# comment the line below if you don't want to see the spinner
# gum spin --spinner globe --title "$TITLE deployment 🚀. Commencing countdown, engines on..." -- sleep 1 

# Set deployment environment and project based on the repository name
case "$REPO_NAME" in
    "reflow")
        ENV="prod"
        SERVICES=($(ls "$INTERNAL_REFLOW_REPO_PATH/deploy/kubernetes/bigblue/services" | sed -E 's/.yaml//' | grep -v "^voyager-" | gum filter --no-limit --placeholder "reflow service(s) to deploy (tab to select multiple, enter to confirm)..."))
        PROJECT="bigblue"
        TAG_REPO="$INTERNAL_REFLOW_REPO_PATH"
        ;;
    "atlas")
        ENV=$(gum choose --header "Choose deployment environment" prod staging)
        SERVICES=($(ls "$INTERNAL_ATLAS_REPO_PATH/tools/k8s/base/services" | sed -E 's/.yaml//' | gum filter --no-limit --placeholder "atlas service(s) to deploy (tab to select multiple, enter to confirm)..."))
        PROJECT="atlas"
        TAG_REPO="$INTERNAL_ATLAS_REPO_PATH"
        ;;
    "voyager")
        ENV="prod"
        SERVICES=($(ls "$INTERNAL_REFLOW_REPO_PATH/deploy/kubernetes/bigblue/services" | sed -E 's/.yaml//' | grep "^voyager-" | gum filter --no-limit --placeholder "voyager service(s) to deploy (tab to select multiple, enter to confirm)..."))
        PROJECT="bigblue"
        TAG_REPO="$INTERNAL_VOYAGER_REPO_PATH"
        ;;
    *)
        echo "🚚 Invalid repository selection."
        exit 1
        ;;
esac

# Check if any services were selected
if [ ${#SERVICES[@]} -eq 0 ]; then
    echo "🙅 No services selected. Aborted."
    exit 1
fi

# Determine the version to deploy from the appropriate repository
VERSION=$(cd "$TAG_REPO" && git tag -l --sort=-creatordate | gum filter --placeholder "version to deploy...")

# Choose deployment mode
MODE=$(gum choose --header "Choose deployment mode" Normal Force)

# Show selected services and confirm
echo "Selected services:"
for SERVICE in "${SERVICES[@]}"; do
    echo "  - $SERVICE"
done

# Confirm the deployment with the chosen settings
SERVICE_LIST=$(printf ", %s" "${SERVICES[@]}")
SERVICE_LIST=${SERVICE_LIST:2}  # Remove leading ", "
if ! gum confirm "Deploy $PROJECT [$SERVICE_LIST]:$VERSION to $ENV (mode: $MODE)?"; then
    echo "🙅 Aborted"
    exit 1
fi

# Deploy each service sequentially
DEPLOYMENT_RESULTS=()
for SERVICE in "${SERVICES[@]}"; do
    echo ""
    echo "🚀 Deploying $PROJECT $SERVICE:$VERSION to $ENV (mode: $MODE)..."
    
    # Deploy based on the chosen mode
    if [ "$MODE" == "Normal" ]; then
        DEPLOYMENT_OUTPUT=$(~/go/bin/just deploy $PROJECT $ENV $SERVICE $VERSION 2>&1 | tee /dev/tty)
    elif [ "$MODE" == "Force" ]; then
        DEPLOYMENT_OUTPUT=$(~/go/bin/just deploy --force $PROJECT $ENV $SERVICE $VERSION 2>&1 | tee /dev/tty)
    fi
    
    # Check deployment result
    if echo "$DEPLOYMENT_OUTPUT" | grep -q "Error:"; then
        echo "❌ $SERVICE deployment failed."
        DEPLOYMENT_RESULTS+=("❌ $SERVICE - deployment failed")
    elif echo "$DEPLOYMENT_OUTPUT" | grep -q "already deployed"; then
        echo "🤷 $SERVICE skipped. $SERVICE:$VERSION is already deployed."
        DEPLOYMENT_RESULTS+=("🤷 $SERVICE - already deployed")
    else
        PREVIOUS_VERSION=$(echo "$DEPLOYMENT_OUTPUT" | grep -o 'Current image:.*' | grep -o 'v.*')
        echo "✅ $SERVICE deployed successfully. Previous version: $PREVIOUS_VERSION"
        DEPLOYMENT_RESULTS+=("✅ $SERVICE - deployed (was $PREVIOUS_VERSION)")
    fi
done

# Summary
echo ""
echo "📊 Deployment Summary:"
for RESULT in "${DEPLOYMENT_RESULTS[@]}"; do
    echo "  $RESULT"
done

# Copy summary to clipboard
SUMMARY=$(printf "%s\n" "${DEPLOYMENT_RESULTS[@]}")
echo "$SUMMARY" | pbcopy
echo ""
echo "📋 Summary copied to clipboard. You can paste it to Slack."

