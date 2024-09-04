# Determine the root directory of the current Git repository (if any)
ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -n "$ROOT" ]; then
    REPO_NAME=$(basename "$ROOT")
    TITLE=$(echo "$REPO_NAME" | tr '[a-z]' '[A-Z]')

    # comment the line below if you don't want to see the spinner
    # gum spin --spinner globe --title "$TITLE deployment 🚀. Commencing countdown, engines on..." -- sleep 1 
    
    # Set deployment environment and project based on the repository name
    case "$REPO_NAME" in
        "reflow")
            ENV="prod"
            SERVICE=$(ls "$ROOT/deploy/kubernetes/bigblue/services" | sed -E 's/.yaml//' | gum filter --placeholder "reflow service to deploy...")
            PROJECT="bigblue"
            ;;
        "atlas")``
            ENV=$(gum choose --header "Choose deployment environment" prod staging)
            SERVICE=$(ls "$ROOT/tools/k8s/base/services" | sed -E 's/.yaml//' | gum filter --placeholder "atlas service to deploy...")
            PROJECT="atlas"
            ;;
        *)
            echo "🚚 Please run this script directly in reflow or atlas repository."
            exit 1
            ;;
    esac
else
    echo "🚚 Please run this script directly in reflow or atlas repository."
    exit 1
fi

# Determine the version to deploy
VERSION=$(git tag -l --sort=-creatordate | gum filter --placeholder "version to deploy...")

# Choose deployment mode
MODE=$(gum choose --header "Choose deployment mode" Normal Force)

# Confirm the deployment with the chosen settings
if ! gum confirm "Deploy $PROJECT $SERVICE:$VERSION to $ENV (mode: $MODE)?"; then
    echo "🙅 Aborted"
    exit 1
fi
echo "🚀 Deploying $PROJECT $SERVICE:$VERSION to $ENV (mode: $MODE)..."

# Deploy based on the chosen mode
if [ "$MODE" == "Normal" ]; then
    DEPLOYMENT_OUTPUT=$(~/go/bin/just deploy $PROJECT $ENV $SERVICE $VERSION 2>&1 | tee /dev/tty)
elif [ "$MODE" == "Force" ]; then
    DEPLOYMENT_OUTPUT=$(~/go/bin/just deploy --force $PROJECT $ENV  $SERVICE $VERSION 2>&1 | tee /dev/tty)
fi

# Check deployment result and copy the deployment status to clipboard if successful.
if echo "$DEPLOYMENT_OUTPUT" | grep -q "Error:"; then
    echo "❌ Deployment failed."
elif echo "$DEPLOYMENT_OUTPUT" | grep -q "already deployed"; then
    echo "🤷 Skipped. $SERVICE:$VERSION is already deployed."
else
    PREVIOUS_VERSION=$(echo "$DEPLOYMENT_OUTPUT" | grep -o 'Current image:.*' | grep -o 'v.*')
    echo "🛰️ Deployed. Previous version is $PREVIOUS_VERSION" | pbcopy
    echo "✅ Deployed. You can paste the deployment status to Slack."
fi

