#!/bin/bash

set -euox pipefail

gcloud config set project "${GCP_PROJECT}"
gcloud services enable cloudbuild.googleapis.com serviceusage.googleapis.com cloudresourcemanager.googleapis.com monitoring.googleapis.com

TF_STATE_BUCKET="gs://${BUCKET_PREFIX}-tfstate"
CLOUDBUILD_STAGING_BUCKET="gs://${BUCKET_PREFIX}-cloudbuild"

gsutil ls -b "${TF_STATE_BUCKET}" ||  gsutil mb "${TF_STATE_BUCKET}"
gsutil versioning set on "${TF_STATE_BUCKET}"

gsutil ls -b "${CLOUDBUILD_STAGING_BUCKET}" ||  gsutil mb "${CLOUDBUILD_STAGING_BUCKET}"

CLOUDBUILD_SA="$(gcloud projects describe $GCP_PROJECT --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$CLOUDBUILD_SA \
    --role roles/editor

# this is required for creating IAM policies for the cluster
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$CLOUDBUILD_SA \
    --role roles/iam.securityAdmin

# this is required for creating IAM policies for the cluster
gcloud projects add-iam-policy-binding $GCP_PROJECT \
    --member serviceAccount:$CLOUDBUILD_SA \
    --role roles/container.admin



