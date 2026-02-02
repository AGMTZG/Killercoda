#!/bin/bash

BASE_DIR=~/app/overlays/prod

if [[ ! -f "$BASE_DIR/kustomization.yaml" ]]; then
    echo "kustomization.yaml not found in $BASE_DIR"
    exit 1
fi

GENERATED_YAML=$(kubectl kustomize "$BASE_DIR") || {
    echo "Error: kustomize build failed."
    exit 1
}

# -------------------------------------------------
# Helper function to get env values from StatefulSet
# -------------------------------------------------
get_env_value () {
  ENV_NAME=$1
  echo "$GENERATED_YAML" | yq eval "
    select(.kind==\"StatefulSet\" and .metadata.name==\"mysql-prod\") |
    .spec.template.spec.containers[] |
    select(.name==\"mysql\") |
    .env[] |
    select(.name==\"$ENV_NAME\") |
    .value
  " -
}

# -----------------------------
# Image check
# -----------------------------
echo "$GENERATED_YAML" | grep -q "image: mysql:prod" || {
    echo "MySQL image not set to mysql:prod"
    exit 1
}

# -----------------------------
# nameSuffix check
# -----------------------------
echo "$GENERATED_YAML" | grep -q "name: mysql-prod" || {
    echo "nameSuffix '-prod' not applied to StatefulSet"
    exit 1
}

# -----------------------------
# Label check
# -----------------------------
echo "$GENERATED_YAML" | grep -q "env: prod" || {
    echo "Label 'env: prod' missing"
    exit 1
}

# -----------------------------
# Annotation check
# -----------------------------
echo "$GENERATED_YAML" | grep -q "resource: production" || {
    echo "Annotation 'resource: production' missing"
    exit 1
}

# -----------------------------
# ConfigMap checks
# -----------------------------
CONFIG_MYSQL_HOST=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="ConfigMap" and .metadata.name=="db-host-prod") | .data.MYSQL_HOST
' -)

CONFIG_MYSQL_PORT=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="ConfigMap" and .metadata.name=="db-host-prod") | .data.MYSQL_PORT
' -)

[[ "$CONFIG_MYSQL_HOST" == "mysql-prod.company.local" ]] || {
    echo "ConfigMap MYSQL_HOST not correct"
    exit 1
}

[[ "$CONFIG_MYSQL_PORT" == "3306" ]] || {
    echo "ConfigMap MYSQL_PORT not correct"
    exit 1
}

# -----------------------------
# Secret checks
# -----------------------------
SECRET_MYSQL_USER=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="Secret" and .metadata.name=="db-secret-prod") | .data.MYSQL_USER
' -)

SECRET_MYSQL_PASSWORD=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="Secret" and .metadata.name=="db-secret-prod") | .data.MYSQL_PASSWORD
' -)

SECRET_MYSQL_DATABASE=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="Secret" and .metadata.name=="db-secret-prod") | .data.MYSQL_DATABASE
' -)

[[ "$(echo "$SECRET_MYSQL_USER" | base64 --decode)" == "prod_admin" ]] || {
    echo "Secret MYSQL_USER not correct"
    exit 1
}

[[ "$(echo "$SECRET_MYSQL_PASSWORD" | base64 --decode)" == "G7hT9pX2!zQ4" ]] || {
    echo "Secret MYSQL_PASSWORD not correct"
    exit 1
}

[[ "$(echo "$SECRET_MYSQL_DATABASE" | base64 --decode)" == "prodInventory" ]] || {
    echo "Secret MYSQL_DATABASE not correct"
    exit 1
}

# -----------------------------
# Replacement checks in StatefulSet
# -----------------------------
[[ "$(get_env_value MYSQL_HOST)" == "mysql-prod.company.local" ]] || {
    echo "MYSQL_HOST not injected into StatefulSet"
    exit 1
}

[[ "$(get_env_value MYSQL_PORT)" == "3306" ]] || {
    echo "MYSQL_PORT not injected into StatefulSet"
    exit 1
}

[[ "$(get_env_value MYSQL_USER)" == "prod_admin" ]] || {
    echo "MYSQL_USER not injected into StatefulSet"
    exit 1
}

[[ "$(get_env_value MYSQL_PASSWORD)" == "G7hT9pX2!zQ4" ]] || {
    echo "MYSQL_PASSWORD not injected into StatefulSet"
    exit 1
}

[[ "$(get_env_value MYSQL_DATABASE)" == "prodInventory" ]] || {
    echo "MYSQL_DATABASE not injected into StatefulSet"
    exit 1
}

echo "✅ All checks passed for prod overlay!"
