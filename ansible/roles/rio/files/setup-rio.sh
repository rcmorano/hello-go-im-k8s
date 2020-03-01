#!/bin/bash

set -x
# let some time (~5mins) for k3s api to be up
for seq in $(seq 1 5)
do
  export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')" || sleep 60
done
# uninstall default k3d ingress (traefik) in favor of rio's gloo
rio install --no-email
kubectl delete service -n kube-system traefik-prometheus traefik
kubectl delete deploy -n kube-system traefik
