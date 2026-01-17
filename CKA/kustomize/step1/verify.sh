#!/bin/bash

BASE_DIR=~/app/overlays/dev

if [[ ! -f "$BASE_DIR/kustomization.yaml" ]]; then
    echo "kustomization.yaml not found in $BASE_DIR"
    exit 1
fi

if [[ ! -f "$BASE_DIR/patch.json" ]]; then
    echo "patch.json not found in $BASE_DIR"
    exit 1
fi

GENERATED_YAML=$(kubectl kustomize "$BASE_DIR")
if [[ $? -ne 0 ]]; then
    echo "Error: kustomize build failed."
    exit 1
fi

# Image check
echo "$GENERATED_YAML" | grep -q "image: mysql:dev" || {
    echo "MySQL image not set to mysql:dev"
    exit 1
}

# nameSuffix check
echo "$GENERATED_YAML" | grep -q "name: mysql-dev" || {
    echo "nameSuffix '-dev' not applied"
    exit 1
}

# Label check
echo "$GENERATED_YAML" | grep -q "env: dev" || {
    echo "Label 'env: dev' missing"
    exit 1
}

# Annotation check
echo "$GENERATED_YAML" | grep -q "resource: development" || {
    echo "Annotation 'resource: development' missing"
    exit 1
}

# Replicas check
REPLICAS=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="StatefulSet") | .spec.replicas
' -)

if [[ "$REPLICAS" != "2" ]]; then
    echo "StatefulSet replicas not set to 2"
    exit 1
fi

# InitContainer checks
INIT_CONTAINER=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="StatefulSet") |
  .spec.template.spec.initContainers[] |
  select(.name=="init-permissions")
' -)

if [[ -z "$INIT_CONTAINER" ]]; then
    echo "init-permissions initContainer missing"
    exit 1
fi

echo "$INIT_CONTAINER" | grep -q "busybox" || {
    echo "init-permissions does not use busybox image"
    exit 1
}

echo "$INIT_CONTAINER" | grep -q "chown -R mysql:mysql /var/lib/mysql" || {
    echo "init-permissions command is incorrect"
    exit 1
}

echo "All checks passed for dev overlay!"
