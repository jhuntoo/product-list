#!/bin/bash

set -euox pipefail

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

gcloud builds submit --config=cloudbuild/teardown.yaml \
  --gcs-source-staging-dir="gs://${STACK_PREFIX}-cloudbuild/source"  \
  --substitutions=_STACK_PREFIX="$STACK_PREFIX",_BUCKET_PREFIX="$BUCKET_PREFIX",_GCP_PROJECT="$GCP_PROJECT" \
  --timeout=3600s \
  .

TF_STATE_BUCKET="gs://${BUCKET_PREFIX}-tfstate"
CLOUDBUILD_STAGING_BUCKET="gs://${BUCKET_PREFIX}-cloudbuild"

gsutil rm -r ${TF_STATE_BUCKET}
gsutil rm -r ${CLOUDBUILD_STAGING_BUCKET}

CLOUDBUILD_SA="$(gcloud projects describe $GCP_PROJECT --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
gcloud projects remove-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$CLOUDBUILD_SA \
    --role roles/editor

# this is required for creating IAM policies for the cluster
gcloud projects remove-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$CLOUDBUILD_SA \
    --role roles/iam.securityAdmin

# this is required for creating IAM policies for the cluster
gcloud projects remove-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$CLOUDBUILD_SA \
    --role roles/container.admin

"${SCRIPTS_DIR}"/remove_repo_from_gcr.sh eu.gcr.io/"${GCP_PROJECT}"/product-list
"${SCRIPTS_DIR}"/remove_repo_from_gcr.sh eu.gcr.io/"${GCP_PROJECT}"/helm