#!/bin/bash

set -euox pipefail

gcloud builds submit --config=cloudbuild.yaml \
  --gcs-source-staging-dir="gs://${BUCKET_PREFIX}-cloudbuild/source"  \
  .