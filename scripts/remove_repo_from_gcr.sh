IFS=$'\n\t'
set -eou pipefail

main(){
  local C=0
  IMAGE="${1}"
  for digest in $(gcloud container images list-tags ${IMAGE} --limit=999999 --sort-by=TIMESTAMP \
    --format='get(digest)'); do
    (
      set -x
      gcloud container images delete -q --force-delete-tags "${IMAGE}@${digest}"
    )
    let C=C+1
  done
  echo "Deleted ${C} images in ${IMAGE}." >&2
}

main "${1}"