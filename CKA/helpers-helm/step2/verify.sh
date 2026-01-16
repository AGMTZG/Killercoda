#!/bin/bash

# Always start from home
cd "$HOME"

# Find the database-app chart directory (max depth to avoid noise)
CHART_DIR=$(find . -maxdepth 3 -type d -name "database-app" | head -n 1)

if [ -z "$CHART_DIR" ]; then
  echo "database-app chart directory not found"
  exit 1
fi

TEMPLATES_DIR="$CHART_DIR/templates"

STATEFULSET_FILE="$TEMPLATES_DIR/statefulset.yaml"
SERVICE_FILE="$TEMPLATES_DIR/headless-service.yaml"
HELPERS_FILE="$TEMPLATES_DIR/_helpers.tpl"

# Basic existence checks
[ -f "$HELPERS_FILE" ] || { echo "_helpers.tpl not found"; exit 1; }
[ -f "$STATEFULSET_FILE" ] || { echo "statefulset.yaml not found"; exit 1; }
[ -f "$SERVICE_FILE" ] || { echo "headless-service.yaml not found"; exit 1; }

# ---- Verify StatefulSet uses helpers ----

grep -q 'include "database-app.name"' "$STATEFULSET_FILE" || {
  echo "StatefulSet does not use database-app.name helper"
  exit 1
}

grep -q 'include "database-app.labels"' "$STATEFULSET_FILE" || {
  echo "StatefulSet does not use database-app.labels helper"
  exit 1
}

grep -q 'include "database-app.selectorLabels"' "$STATEFULSET_FILE" || {
  echo "StatefulSet does not use database-app.selectorLabels helper"
  exit 1
}

# ---- Verify Headless Service uses helpers ----

grep -q 'include "database-app.name"' "$SERVICE_FILE" || {
  echo "Service does not use database-app.name helper"
  exit 1
}

grep -q 'include "database-app.labels"' "$SERVICE_FILE" || {
  echo "Service does not use database-app.labels helper"
  exit 1
}

grep -q 'include "database-app.selectorLabels"' "$SERVICE_FILE" || {
  echo "Service does not use database-app.selectorLabels helper"
  exit 1
}

echo "Helm chart templates successfully verified using helpers"

