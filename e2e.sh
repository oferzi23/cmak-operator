#!/bin/bash
set -x
set -e

REGISTRY='registry.localhost'
if [ -z $CI ];then
  REGISTRY='192.168.99.103'
fi

skaffold config set default-repo "${REGISTRY}:5000"
touch values-dev.yaml
skaffold run -p e2e

[ "$(helm ls --deployed -q | wc -l)" -eq 1 ]

kubectl port-forward deploy/cmak 9000:9000 &

[ "$(curl -s http://localhost:9000/api/status/clusters | jq '.clusters.active | length')" -eq 2 ]

kill $!

