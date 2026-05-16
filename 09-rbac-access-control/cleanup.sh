#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl is required." >&2; exit 1; }

echo "Deleting RBAC resources..."
kubectl delete -f rbac-roles.yaml --ignore-not-found

echo "Deleting mongo-express resources..."
kubectl delete -f mongo-express.yaml --ignore-not-found

echo "Deleting MongoDB resources..."
kubectl delete -f mongodb.yaml --ignore-not-found

echo "Deleting environment resources..."
kubectl delete -f environement.yaml --ignore-not-found

echo "Cleanup complete."
