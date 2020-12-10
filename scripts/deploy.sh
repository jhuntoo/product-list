#!/bin/bash

set -euox pipefail

gcloud builds submit --config=cloudbuild/build_deploy.yaml \
  --gcs-source-staging-dir="gs://${BUCKET_PREFIX}-cloudbuild/source"  \
  --substitutions=_STACK_PREFIX="$STACK_PREFIX",_BUCKET_PREFIX="$BUCKET_PREFIX",_GCP_PROJECT="$GCP_PROJECT" \
  --timeout=3600s \
  .