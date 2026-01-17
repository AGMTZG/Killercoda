#!/bin/bash

BASE_DIR=~/app/overlays/prod

if [[ ! -f "$BASE_DIR/kustomization.yaml" ]]; then
    echo "kustomization.yaml not found in $BASE_DIR"
    exit 1
fi

GENERATED_YAML=$(kubectl kustomize "$BASE_DIR")
if [[ $? -ne 0 ]]; then
    echo "Error: kustomize build failed."
    exit 1
fi

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
CONFIG_DB_HOST=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="ConfigMap" and .metadata.name=="db-host-prod") | .data.DB_HOST
' -)

CONFIG_DB_PORT=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="ConfigMap" and .metadata.name=="db-host-prod") | .data.DB_PORT
' -)

if [[ "$CONFIG_DB_HOST" != "mysql-prod.company.local" ]]; then
    echo "ConfigMap DB_HOST not correct"
    exit 1
fi

if [[ "$CONFIG_DB_PORT" != "3306" ]]; then
    echo "ConfigMap DB_PORT not correct"
    exit 1
fi

# -----------------------------
# Secret checks
# -----------------------------
SECRET_USERNAME=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="Secret" and .metadata.name=="db-secret-prod") | .data.USERNAME
' -)

SECRET_PASSWORD=$(echo "$GENERATED_YAML" | yq eval '
  select(.kind=="Secret" and .metadata.name=="db-secret-prod") | .data.PASSWORD
' -)

DECODED_SECRET_USERNAME=$(echo "$SECRET_USERNAME" | base64 --decode)
DECODED_SECRET_PASSWORD=$(echo "$SECRET_PASSWORD" | base64 --decode)

if [[ "$DECODED_SECRET_USERNAME" != "prod_admin" ]]; then
    echo "Secret USERNAME not correct"
    exit 1
fi

if [[ "$DECODED_SECRET_PASSWORD" != "G7hT9pX2!zQ4" ]]; then
    echo "Secret PASSWORD not correct"
    exit 1
fi

# -----------------------------
# Replacement checks in StatefulSet
# -----------------------------
DB_HOST_VALUE=$(get_env_value DB_HOST)
DB_PORT_VALUE=$(get_env_value DB_PORT)
MYSQL_USER_VALUE=$(get_env_value MYSQL_USER)
MYSQL_PASSWORD_VALUE=$(get_env_value MYSQL_PASSWORD)

if [[ "$DB_HOST_VALUE" != "mysql-prod.company.local" ]]; then
    echo "DB_HOST not injected into StatefulSet"
    exit 1
fi

if [[ "$DB_PORT_VALUE" != "3306" ]]; then
    echo "DB_PORT not injected into StatefulSet"
    exit 1
fi

DECODED_MYSQL_USER=$(echo "$MYSQL_USER_VALUE" | base64 --decode)
DECODED_MYSQL_PASSWORD=$(echo "$MYSQL_PASSWORD_VALUE" | base64 --decode)

if [[ "$DECODED_MYSQL_USER" != "prod_admin" ]]; then
    echo "MYSQL_USER not injected into StatefulSet"
    exit 1
fi

if [[ "$DECODED_MYSQL_PASSWORD" != "G7hT9pX2!zQ4" ]]; then
    echo "MYSQL_PASSWORD not injected into StatefulSet"
    exit 1
fi

echo "All checks passed for prod overlay!"

