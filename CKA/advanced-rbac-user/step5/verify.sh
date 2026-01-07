#!/bin/sh

KUBECONFIG=~/.kube/config
ALICE_CONTEXT="alice-context"
NAMESPACE="projectx"
USER="alice"

CURRENT_CONTEXT=$(kubectl --kubeconfig="$KUBECONFIG" config current-context)

echo "Current context: $CURRENT_CONTEXT"
echo "Namespace: $NAMESPACE"
echo

# Validate that alice-context exists (but do NOT switch)
kubectl --kubeconfig="$KUBECONFIG" config get-contexts "$ALICE_CONTEXT" >/dev/null 2>&1 || {
    echo "FAIL: alice-context not found"
    exit 1
}

if [ "$CURRENT_CONTEXT" = "$ALICE_CONTEXT" ]; then
  echo "Running checks as alice (real context)"
  echo

  # Can create pods
  kubectl auth can-i create pods -n "$NAMESPACE" \
    | grep -q yes \
    && echo "OK: alice can create pods" \
    || { echo "FAIL: alice cannot create pods"; exit 1; }

  # Cannot create deployments
  kubectl auth can-i create deployments -n "$NAMESPACE" \
    | grep -q no \
    && echo "OK: alice cannot create deployments" \
    || { echo "FAIL: alice should NOT create deployments"; exit 1; }

  # Can list pods
  kubectl auth can-i list pods -n "$NAMESPACE" \
    | grep -q yes \
    && echo "OK: alice can list pods" \
    || { echo "FAIL: alice cannot list pods"; exit 1; }

  # Cannot get secrets
  kubectl auth can-i get secrets -n "$NAMESPACE" \
    | grep -q no \
    && echo "OK: alice cannot get secrets" \
    || { echo "FAIL: alice should NOT get secrets"; exit 1; }

else
  echo "Running checks from non-alice context (impersonation)"
  echo

  # Can create pods
  kubectl auth can-i create pods -n "$NAMESPACE" --as="$USER" \
    | grep -q yes \
    && echo "OK: alice can create pods" \
    || { echo "FAIL: alice cannot create pods"; exit 1; }

  # Cannot create deployments
  kubectl auth can-i create deployments -n "$NAMESPACE" --as="$USER" \
    | grep -q no \
    && echo "OK: alice cannot create deployments" \
    || { echo "FAIL: alice should NOT create deployments"; exit 1; }

  # Can list pods
  kubectl auth can-i list pods -n "$NAMESPACE" --as="$USER" \
    | grep -q yes \
    && echo "OK: alice can list pods" \
    || { echo "FAIL: alice cannot list pods"; exit 1; }

  # Cannot get secrets
  kubectl auth can-i get secrets -n "$NAMESPACE" --as="$USER" \
    | grep -q no \
    && echo "OK: alice cannot get secrets" \
    || { echo "FAIL: alice should NOT get secrets"; exit 1; }
fi

echo
echo "SUCCESS: alice RBAC verification passed"
