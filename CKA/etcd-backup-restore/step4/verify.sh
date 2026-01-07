#!/bin/bash

ETCD_DATA_DIR="/mnt/etcd-data"
MANIFESTS=(
  /etc/kubernetes/manifests/kube-apiserver.yaml
  /etc/kubernetes/manifests/kube-controller-manager.yaml
)

echo "Checking etcd data restore..."

if [ ! -d "$ETCD_DATA_DIR" ] || [ -z "$(ls -A "$ETCD_DATA_DIR")" ]; then
  echo "FAIL: etcd data directory missing or empty"
  exit 1
fi

echo "OK: etcd data directory restored"

echo
echo "Checking control plane manifests..."

for manifest in "${MANIFESTS[@]}"; do
  if [ ! -f "$manifest" ]; then
    echo "FAIL: $manifest is missing"
    exit 1
  fi
  echo "OK: $manifest exists"
done

echo
echo "SUCCESS: etcd snapshot restore verification passed"
