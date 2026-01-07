#!/bin/bash

KUBECONFIG=~/.kube/config
DEPLOYBOT_CONTEXT="deploybot-context"
NAMESPACE="appenv"
SERVICEACCOUNT="deploybot"
AS="system:serviceaccount:${NAMESPACE}:${SERVICEACCOUNT}"

CURRENT_CONTEXT=$(kubectl --kubeconfig="$KUBECONFIG" config current-context)

echo "Current context: $CURRENT_CONTEXT"
echo "Namespace: $NAMESPACE"
echo

if [ "$CURRENT_CONTEXT" = "$DEPLOYBOT_CONTEXT" ]; then
  echo "Running checks as deploybot (real context)"
  echo

  # Can create deployments
  kubectl auth can-i create deployments -n "$NAMESPACE" \
    | grep -q yes \
    && echo "OK: deploybot can create deployments" \
    || { echo "FAIL: deploybot cannot create deployments"; exit 1; }

  # Can list replicasets
  kubectl get replicasets -n "$NAMESPACE" >/dev/null 2>&1 \
    && echo "OK: deploybot can list replicasets" \
    || { echo "FAIL: deploybot cannot list replicasets"; exit 1; }

  # Cannot create pods
  kubectl auth can-i create pods -n "$NAMESPACE" \
    | grep -q no \
    && echo "OK: deploybot cannot create pods" \
    || { echo "FAIL: deploybot pod permissions incorrect"; exit 1; }

  # Can delete deployments
  kubectl auth can-i delete deployments -n "$NAMESPACE" \
    | grep -q yes \
    && echo "OK: deploybot can delete deployments" \
    || { echo "FAIL: deploybot cannot delete deployments"; exit 1; }

  # Cannot get secrets
  kubectl auth can-i get secrets -n "$NAMESPACE" \
    | grep -q no \
    && echo "OK: deploybot cannot get secrets" \
    || { echo "FAIL: deploybot secrets access incorrect"; exit 1; }

else
  echo "Running checks from non-deploybot context (impersonation)"
  echo

  kubectl auth can-i create deployments -n "$NAMESPACE" --as="$AS" \
    | grep -q yes \
    && echo "OK: deploybot can create deployments" \
    || { echo "FAIL: deploybot cannot create deployments"; exit 1; }

  kubectl auth can-i list replicasets -n "$NAMESPACE" --as="$AS" \
    | grep -q yes \
    && echo "OK: deploybot can list replicasets" \
    || { echo "FAIL: deploybot cannot list replicasets"; exit 1; }

  kubectl auth can-i create pods -n "$NAMESPACE" --as="$AS" \
    | grep -q no \
    && echo "OK: deploybot cannot create pods" \
    || { echo "FAIL: deploybot pod permissions incorrect"; exit 1; }

  kubectl auth can-i delete deployments -n "$NAMESPACE" --as="$AS" \
    | grep -q yes \
    && echo "OK: deploybot can delete deployments" \
    || { echo "FAIL: deploybot cannot delete deployments"; exit 1; }

  kubectl auth can-i get secrets -n "$NAMESPACE" --as="$AS" \
    | grep -q no \
    && echo "OK: deploybot cannot get secrets" \
    || { echo "FAIL: deploybot secrets access incorrect"; exit 1; }
fi

echo
echo "SUCCESS: deploybot RBAC verification passed"
