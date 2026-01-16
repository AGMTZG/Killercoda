
#!/bin/bash

cd "$HOME"

# Find the database-app chart directory
CHART_DIR=$(find . -type d -name "database-app" -maxdepth 3 | head -n 1)

if [ -z "$CHART_DIR" ]; then
  echo "database-app chart directory not found"
  exit 1
fi

HELPERS_FILE="$CHART_DIR/templates/_helpers.tpl"

if [ ! -f "$HELPERS_FILE" ]; then
  echo "_helpers.tpl not found in $CHART_DIR/templates"
  exit 1
fi

# Check required helpers
grep -q 'define "database-app.name"' "$HELPERS_FILE" || {
  echo "database-app.name helper not found"
  exit 1
}

grep -q 'define "database-app.fullname"' "$HELPERS_FILE" || {
  echo "database-app.fullname helper not found"
  exit 1
}

grep -q 'define "database-app.labels"' "$HELPERS_FILE" || {
  echo "database-app.labels helper not found"
  exit 1
}

grep -q 'define "database-app.selectorLabels"' "$HELPERS_FILE" || {
  echo "database-app.selectorLabels helper not found"
  exit 1
}

echo "Helm helper templates verified successfully"


