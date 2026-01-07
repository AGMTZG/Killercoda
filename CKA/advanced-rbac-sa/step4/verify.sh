#!/bin/bash

KUBECONFIG=~/.kube/config
SERVICEACCOUNT=deploybot
NAMESPACE=appenv

if kubectl --kubeconfig="$KUBECONFIG" auth can-i create deployments --as=system:serviceaccount:${NAMESPACE}:${SERVICEACCOUNT} -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "deploybot can create deployments"
else
    echo "deploybot cannot create deployments"
    exit 1
fi

if kubectl --kubeconfig="$KUBECONFIG" auth can-i list replicasets  --as=system:serviceaccount:${NAMESPACE}:${SERVICEACCOUNT} -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "deploybot can list replicasets"
else
    echo "deploybot cannot list replicasets"
    exit 1
fi

if kubectl --kubeconfig="$KUBECONFIG" auth can-i create pods --as=system:serviceaccount:${NAMESPACE}:${SERVICEACCOUNT} -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "deploybot can create pods (should NOT be able to)"
    exit 1
else
    echo "deploybot cannot create pods"
fi

if kubectl --kubeconfig="$KUBECONFIG" auth can-i delete deployments  --as=system:serviceaccount:${NAMESPACE}:${SERVICEACCOUNT} -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "deploybot can delete deployments"
else
    echo "deploybot cannot delete deployments"
    exit 1
fi

if kubectl --kubeconfig="$KUBECONFIG" auth can-i get secrets --as=system:serviceaccount:${NAMESPACE}:${SERVICEACCOUNT} -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "deploybot can get secrets (should NOT be able to)"
    exit 1
else
    echo "deploybot cannot get secrets"
fi
