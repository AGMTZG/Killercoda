#!/bin/bash

KUBECONFIG=~/.kube/config
DEPLOYBOT_CONTEXT="deploybot-context"
NAMESPACE="appenv"
SERVICEACCOUNT="deploybot"
AS="system:serviceaccount:${NAMESPACE}:${SERVICEACCOUNT}"

CURRENT_CONTEXT=$(kubectl --kubeconfig="$KUBECONFIG" config current-context)

echo "Current context: $CURRENT_CONTEXT"

if [ "$CURRENT_CONTEXT" = "$DEPLOYBOT_CONTEXT" ]; then
  echo "Running checks as deploybot (real execution)"

  kubectl create deployment nginx --image=nginx -n "$NAMESPACE" >/dev/null 2>&1 \
    && echo "OK: deploybot can create deployments" \
    || { echo "FAIL: cannot create deployments"; exit 1; }

  kubectl get replicasets -n "$NAMESPACE" >/dev/null \
    && echo "OK: deploybot can list replicasets" \
    || { echo "FAIL: cannot list replicasets"; exit 1; }

  if kubectl run test-pod --image=nginx -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "FAIL: deploybot should NOT create pods"
    exit 1
  else
    echo "OK: deploybot cannot create pods"
  fi

  kubectl auth can-i delete deployments -n "$NAMESPACE" \
    | grep -q yes && echo "OK: deploybot can delete deployments" \
    || { echo "FAIL: cannot delete deployments"; exit 1; }

  kubectl auth can-i get secrets -n "$NAMESPACE" \
    | grep -q no && echo "OK: deploybot cannot get secrets" \
    || { echo "FAIL: secrets access wrong"; exit 1; }

else
  echo "Running checks from admin context (impersonation)"

  kubectl auth can-i create deployments -n "$NAMESPACE" --as="$AS" \
    | grep -q yes && echo "OK: deploybot can create deployments" \
    || { echo "FAIL: cannot create deployments"; exit 1; }

  kubectl auth can-i list replicasets -n "$NAMESPACE" --as="$AS" \
    | grep -q yes && echo "OK: deploybot can list replicasets" \
    || { echo "FAIL: cannot list replicasets"; exit 1; }

  kubectl auth can-i create pods -n "$NAMESPACE" --as="$AS" \
    | grep -q no && echo "OK: deploybot cannot create pods" \
    || { echo "FAIL: pod creation wrong"; exit 1; }

  kubectl auth can-i delete deployments -n "$NAMESPACE" --as="$AS" \
    | grep -q yes && echo "OK: deploybot can delete deployments" \
    || { echo "FAIL: cannot delete deployments"; exit 1; }

  kubectl auth can-i get secrets -n "$NAMESPACE" --as="$AS" \
    | grep -q no && echo "OK: deploybot cannot get secrets" \
    || { echo "FAIL: secrets access wrong"; exit 1; }
fi
