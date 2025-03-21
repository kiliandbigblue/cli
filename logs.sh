#!/bin/bash

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
        # Allow multiple service selection
        SERVICES=$(ls "$ROOT/deploy/kubernetes/bigblue/services" | sed -E 's/.yaml//' | gum filter --no-limit --placeholder "Select reflow service(s) to deploy...")
        PROJECT="bigblueprod"
        PREFIX="bigblue-"
        ;;
    "atlas")
        ROOT=$INTERNAL_ATLAS_REPO_PATH
        ENV=$(gum choose --header "Choose deployment environment" atlas-prod atlas-staging)
        # Allow multiple service selection
        SERVICES=$(ls "$ROOT/tools/k8s/base/services" | sed -E 's/.yaml//' | gum filter --no-limit --placeholder "Select atlas service(s) to deploy...")
        PROJECT="bigblue-atlas-prod"
        PREFIX="atlas-"
        ;;
    *)
        echo "Invalid repository name."
        exit 1
        ;;
esac

# Build the query for multiple services
QUERY="resource.labels.namespace_name=\"$ENV\""

# Build the services part of the query
if [ -n "$SERVICES" ]; then
    # Create array of service names with prefix
    FULL_SERVICES=()
    for SERVICE in $SERVICES; do
        FULL_SERVICES+=("$PREFIX$SERVICE")
    done
    
    # Join services with OR for the query
    if [ ${#FULL_SERVICES[@]} -gt 1 ]; then
        QUERY+=" AND (labels.\"k8s-pod/app_kubernetes_io/name\"=\"${FULL_SERVICES[0]}\""
        for ((i=1; i<${#FULL_SERVICES[@]}; i++)); do
            QUERY+=" OR labels.\"k8s-pod/app_kubernetes_io/name\"=\"${FULL_SERVICES[$i]}\""
        done
        QUERY+=")"
    else
        QUERY+=" AND labels.\"k8s-pod/app_kubernetes_io/name\"=\"${FULL_SERVICES[0]}\""
    fi
fi

# Add a newline at the end of the query as seen in the example URL
QUERY+=$'\n'

# URL encode the query
ENCODED_QUERY=$(echo "$QUERY" | perl -MURI::Escape -ne 'print uri_escape($_)')

# Get timestamps
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%S.%NZ" -d "30 minutes ago")

# Add summary fields parameter for grouping by service name
SUMMARY_FIELDS="labels%252F%2522k8s-pod%252Fapp_kubernetes_io%252Fname%2522:false:32:beginning"

# Forge the URL of the logs to open with all parameters
URL="https://console.cloud.google.com/logs/query;query=$ENCODED_QUERY;summaryFields=$SUMMARY_FIELDS;startTime=$START_TIME?project=$PROJECT&inv=1&invt=AbsAVQ"

echo "🔍 Opening logs of $PROJECT multiple services in $ENV..."
echo "Selected services: $(echo "$SERVICES" | sed "s/ /, $PREFIX/g" | sed "s/^/$PREFIX/")"
echo "Query: $QUERY"
open "$URL"
