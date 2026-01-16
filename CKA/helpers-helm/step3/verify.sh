#!/bin/bash

RELEASE_NAME="my-database-release"

if helm status "$RELEASE_NAME" &> /dev/null; then
    echo "Helm release '$RELEASE_NAME' is installed."
    exit 0
else
    echo "Helm release '$RELEASE_NAME' is not installed."
    exit 1
fi
