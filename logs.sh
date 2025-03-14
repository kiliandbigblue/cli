
DEFAULT_REFLOW_REPO_PATH=~/projects/reflow
DEFAULT_ATLAS_REPO_PATH=~/projects/atlas

# Use the default path or read from ENV variables
INTERNAL_REFLOW_REPO_PATH=${REFLOW_REPO_PATH:-$DEFAULT_REFLOW_REPO_PATH}
INTERNAL_ATLAS_REPO_PATH=${ATLAS_REPO_PATH:-$DEFAULT_ATLAS_REPO_PATH}

REPO_NAME=$(gum choose --header "Choose repository" reflow atlas) 

# Set deployment environment and project based on the repository name
case "$REPO_NAME" in
    "reflow")
        ROOT=$INTERNAL_REFLOW_REPO_PATH
        ENV="bigblue-prod"
        SERVICE=bigblue-$(ls "$ROOT/deploy/kubernetes/bigblue/services" | sed -E 's/.yaml//' | gum filter --placeholder "reflow service to deploy...")
        PROJECT="bigblueprod"
        ;;
    "atlas")``
        ROOT=$INTERNAL_ATLAS_REPO_PATH
        ENV=$(gum choose --header "Choose deployment environment" atlas-prod atlas-staging)
        SERVICE=atlas-$(ls "$ROOT/tools/k8s/base/services" | sed -E 's/.yaml//' | gum filter --placeholder "atlas service to deploy...")
        PROJECT="bigblue-atlas-prod"
        ;;
    *)
        echo "Invalid repository name."
        exit 1
        ;;
esac

# Forge the URL of the logs to open
URL="https://console.cloud.google.com/logs/query;query=resource.labels.namespace_name%3D%22$ENV%22%0Alabels.%22k8s-pod%2Fapp_kubernetes_io%2Fname%22%3D%22$SERVICE%22;startTime=$(date +%s)?project=$PROJECT"
echo "🔍 Opening logs of $PROJECT $SERVICE in $ENV..."
open "$URL"

