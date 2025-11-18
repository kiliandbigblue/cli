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

# Set deployment environment, namespace, context and project based on the repository name
case "$REPO_NAME" in
    "reflow")
        ENV="prod"
        SERVICE=$(ls "$INTERNAL_REFLOW_REPO_PATH/deploy/kubernetes/bigblue/services" | sed -E 's/.yaml//' | grep -v "^voyager-" | gum filter --placeholder "reflow service to restart...")
        PROJECT="bigblue"
        NAMESPACE="bigblue-prod"
        CONTEXT="gke_bigblueprod_europe-west1_bigblue-primary"
        SERVICE="bigblue-$SERVICE"
        ;;
    "atlas")
        ENV=$(gum choose --header "Choose environment" prod staging)
        SERVICE=$(ls "$INTERNAL_ATLAS_REPO_PATH/tools/k8s/base/services" | sed -E 's/.yaml//' | gum filter --placeholder "atlas service to restart...")
        PROJECT="atlas"
        if [ "$ENV" == "prod" ]; then
            NAMESPACE="atlas-prod"
        else
            NAMESPACE="atlas-staging"
        fi
        CONTEXT="gke_bigblue-atlas-prod_europe-west1_atlas-primary"
        SERVICE="bigblue-$SERVICE"
        ;;
    "voyager")
        ENV="prod"
        SERVICE=$(ls "$INTERNAL_REFLOW_REPO_PATH/deploy/kubernetes/bigblue/services" | sed -E 's/.yaml//' | grep "^voyager-" | gum filter --placeholder "voyager service to restart...")
        PROJECT="bigblue"
        NAMESPACE="bigblue-prod"
        CONTEXT="gke_bigblueprod_europe-west1_bigblue-primary"
        SERVICE="bigblue-$SERVICE"
        ;;
    *)
        echo "🚚 Invalid repository selection."
        exit 1
        ;;
esac

# Check if a service was selected
if [ -z "$SERVICE" ]; then
    echo "🙅 No service selected. Aborted."
    exit 1
fi

# Confirm the restart with the chosen settings
if ! gum confirm "Restart $PROJECT $SERVICE in $ENV?"; then
    echo "🙅 Aborted"
    exit 1
fi

echo ""
echo "🔄 Restarting $PROJECT $SERVICE in $ENV..."

# Switch context and restart the deployment
kubectx $CONTEXT

if kubectl --namespace $NAMESPACE rollout restart deployment $SERVICE; then
    echo "✅ $SERVICE restart initiated successfully."
    echo ""
    echo "📊 Checking rollout status..."
    kubectl --namespace $NAMESPACE rollout status deployment $SERVICE
else
    echo "❌ $SERVICE restart failed."
    exit 1
fi

