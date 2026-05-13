#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

NAMESPACE="${NAMESPACE:-default}"
RELEASE_NAME="${RELEASE_NAME:-community-operator}"
DB_RESOURCE_FILE="${DB_RESOURCE_FILE:-database.yaml}"
MONGO_EXPRESS_FILE="${MONGO_EXPRESS_FILE:-mongo-express.yaml}"
INGRESS_FILE="${INGRESS_FILE:-ingress.yaml}"
SECRET_NAME="${SECRET_NAME:-mongo-admin-password}"

command -v helm >/dev/null 2>&1 || { echo "ERROR: helm is required." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl is required." >&2; exit 1; }

echo "Deleting ingress resource..."
kubectl delete -f "$INGRESS_FILE" --namespace "$NAMESPACE" --ignore-not-found=true

echo "Deleting mongo-express resources..."
kubectl delete -f "$MONGO_EXPRESS_FILE" --namespace "$NAMESPACE" --ignore-not-found=true

echo "Deleting MongoDB custom resource..."
kubectl delete -f "$DB_RESOURCE_FILE" --namespace "$NAMESPACE" --ignore-not-found=true

echo "Deleting MongoDB admin secret..."
kubectl delete secret "$SECRET_NAME" --namespace "$NAMESPACE" --ignore-not-found=true

echo "Uninstalling Helm release '$RELEASE_NAME'..."
helm uninstall "$RELEASE_NAME" --namespace "$NAMESPACE" >/dev/null 2>&1 || true

echo "Cleanup complete."
