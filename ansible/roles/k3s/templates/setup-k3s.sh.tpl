#!/bin/bash

# thx to: https://github.com/rancher/k3d/blob/master/docs/examples.md#running-on-filesystems-k3s-doesnt-like-btrfs-tmpfs-
# TODO: contribute fix for images volume

CLUSTER_NAME="${CLUSTER_NAME:-k3s-default}"
NUM_WORKERS="${NUM_WORKERS:-1}"
# NOTE: this is 3x = 30gb
VOLUMES_SIZE="${VOLUMES_SIZE:-10Gib}"

PLUGIN_LS_OUT=`docker plugin ls --format '{{.Name}},{{.Enabled}}' | grep -E '^ashald/docker-volume-loopback'`
[ -z "${PLUGIN_LS_OUT}" ] && docker plugin install --grant-all-permissions ashald/docker-volume-loopback DATA_DIR=/tmp/docker-loop/data
sleep 3
[ "${PLUGIN_LS_OUT##*,}" != "true" ] && docker plugin enable ashald/docker-volume-loopback

K3D_MOUNTS=()
for i in `seq 0 ${NUM_WORKERS}`; do
  [ ${i} -eq 0 ] && VOLUME_NAME="k3d-${CLUSTER_NAME}-server" || VOLUME_NAME="k3d-${CLUSTER_NAME}-worker-$((${i}-1))" || VOLUME_NAME="k3d-${CLUSTER_NAME}-images"
  docker volume create -d ashald/docker-volume-loopback ${VOLUME_NAME} -o sparse=true -o fs=ext4 -o size=${VOLUMES_SIZE}
  K3D_MOUNTS="$K3D_MOUNTS -v ${VOLUME_NAME}:/var/lib/rancher/k3s@${VOLUME_NAME}"
done

if ! k3d get-kubeconfig --name='k3s-default'
then
  k3d create \
    $K3D_MOUNTS \
    --auto-restart \
    _k3s_enable_registry_ \
    --registry-name _k3s_registry_hostname_ \
    --publish _k3s_ingress_http_port_:80 \
    --publish _k3s_ingress_https_port_:443 \
    --publish 8082:30080@k3d-k3s-default-server
fi

export KUBECONFIG="$(k3d get-kubeconfig --name='k3s-default')"

curl -sL https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
