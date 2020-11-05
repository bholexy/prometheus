#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

GCS_BUCKET_NAME="gs://roava-prometheus" 

# setup for helm-gcs plugin
echo "Output HELM_SERVICE_ACCOUNT_KEY secret "
echo "${HELM_SERVICE_ACCOUNT_KEY}"
echo "${HELM_SERVICE_ACCOUNT_KEY}" > helm-svc-account.json
echo "run cat on helm-svc-account.json"
cat helm-svc-account.json
export GOOGLE_APPLICATION_CREDENTIALS=helm-svc-account.json

# initializing helm repo
# (only needed on first run, but will do nothing if already exists)
echo "Initializing helm repo"
helm gcs init ${GCS_BUCKET_NAME}

# add gcs bucket as helm repo
echo "Adding gcs bucket repo ${GCS_BUCKET_NAME}"
helm repo add private ${GCS_BUCKET_NAME}

FILE=helm-svc-account.json
if [ -f "$FILE" ]; then
    echo "$FILE ::::::::::::::::::::::::::::::::::exists.::::::::::::::::::::::::::::::::::::::::::::"
else 
    echo "$FILE xxxxxxxxxxxxxxxxxxxxxxdoes not existxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx."
fi




chart_file=$(helm package prometheus | awk '{print $NF}')

echo "Pushing $chart_file..."
helm gcs push "$chart_file" private

