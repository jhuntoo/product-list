#!/bin/bash

set -euox pipefail

nodepool_prefix=$1
nodepool_index=$2
cluster_name=$3
region=$4
project=$5

if ! terraform state list | grep "google_container_node_pool.${nodepool_prefix}[${nodepool_index}]"; then
  echo "New node pool, no node pool drain required."
  exit 0
fi

nodepool_name=$(terraform state show -no-color "google_container_node_pool.${nodepool_prefix}[${nodepool_index}]" | grep '[[:space:]]name[[:space:]]' | awk '{ print $3 }' | tr -d \")

# long nodepool names (i.e. "np-nonpreemptible") get truncated in the actual node name...
short_nodepool_name=$(echo "${nodepool_name}" | awk '{print substr($0,0,14)}')

# Connect to the kubernetes cluster
gcloud container clusters get-credentials "${cluster_name}" --region "${region}" --project "${project}"

# disable autoscaling on the nodepool we're about to drain/destroy
while ! gcloud container clusters update "${cluster_name}" --no-enable-autoscaling --node-pool "${nodepool_name}" --project "${project}" --region "${region}"; do
  echo "Retrying again after 60s to disable autoscaling in ${nodepool_name}"
  sleep 60
done

nodes=$(kubectl get nodes | grep "${short_nodepool_name}" | awk '{print $1}')

echo "${nodes}" | xargs kubectl cordon

for node in $nodes; do
  kubectl drain --force --ignore-daemonsets --delete-local-data "${node}"
  echo "$(date) Waiting 60 seconds for pods to start on new node pool...."
  sleep 60
done
