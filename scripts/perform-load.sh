set -euox pipefail

docker run --rm -it peterevans/vegeta sh -c \
  "echo 'GET http://${LOADBALANCER_IP}' | vegeta attack -rate=5 -duration=5m | vegeta encode"