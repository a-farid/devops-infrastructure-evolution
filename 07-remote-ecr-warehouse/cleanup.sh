#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

NAMESPACE="${NAMESPACE:-default}"
DEPLOYMENT_FILE="${DEPLOYMENT_FILE:-deployment.yaml}"
SECRET_FILE="${SECRET_FILE:-ecr-secret.yaml}"

command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl is required." >&2; exit 1; }

echo "Cleaning up ECR deployment resources in namespace '$NAMESPACE'..."

# Delete the deployment
if kubectl get -f "$DEPLOYMENT_FILE" --namespace "$NAMESPACE" >/dev/null 2>&1; then
    kubectl delete -f "$DEPLOYMENT_FILE" --namespace "$NAMESPACE"
    echo "Deployment from '$DEPLOYMENT_FILE' deleted."
else
    echo "Deployment from '$DEPLOYMENT_FILE' not found, skipping."
fi

# Delete the secret
if kubectl get -f "$SECRET_FILE" --namespace "$NAMESPACE" >/dev/null 2>&1; then
    kubectl delete -f "$SECRET_FILE" --namespace "$NAMESPACE"
    echo "Secret from '$SECRET_FILE' deleted."
else
    echo "Secret from '$SECRET_FILE' not found, skipping."
fi

echo "Cleanup completed successfully."