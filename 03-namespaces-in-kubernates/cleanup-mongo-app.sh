#!/usr/bin/env bash

# cleanup-mongo-app.sh
# Removes all MongoDB and Mongo-Express resources from both namespaces.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/4] Deleting Mongo-Express from app-namespace..."
kubectl delete -f mongo-express.yaml -n app-namespace --ignore-not-found=true

echo "[2/4] Deleting MongoDB from database-namespace..."
kubectl delete -f mongo.yaml -n database-namespace --ignore-not-found=true

echo "[3/4] Deleting Secrets and ConfigMaps from database-namespace..."
kubectl delete -f mongo-configmap.yaml -n database-namespace --ignore-not-found=true

echo "[4/4] Deleting namespaces..."
kubectl delete -f namespaces.yaml --ignore-not-found=true

printf "\nCleanup complete. Remaining namespaces:\n"
kubectl get namespaces

printf "\nTo stop Minikube, run: minikube stop\n"