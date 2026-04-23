#!/usr/bin/env bash

# cleanup-mongo-app.sh
# Removes all MongoDB and Mongo-Express resources from the cluster.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/3] Deleting Mongo-Express Deployment and Service..."
kubectl delete -f mongo-express.yaml --ignore-not-found=true

echo "[2/3] Deleting MongoDB Deployment and Service..."
kubectl delete -f mongo.yaml --ignore-not-found=true

echo "[3/3] Deleting Secrets and ConfigMaps..."
kubectl delete -f mongo-secret.yaml -f mongo-configmap.yaml --ignore-not-found=true

printf "\nCleanup complete. Remaining resources:\n"
kubectl get all --ignore-not-found=true

printf "\nTo stop Minikube, run: minikube stop\n"