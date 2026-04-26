#!/usr/bin/env bash

# cleanup-mongo-app.sh
# Removes all MongoDB, Mongo-Express, and Ingress resources from both namespaces.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/5] Deleting Ingress..."
kubectl delete -f ingress.yaml -n app-namespace --ignore-not-found=true

echo "[2/5] Deleting Mongo-Express from app-namespace..."
kubectl delete -f mongo-express.yaml -n app-namespace --ignore-not-found=true

echo "[3/5] Deleting MongoDB from database-namespace..."
kubectl delete -f mongo.yaml -n database-namespace --ignore-not-found=true

echo "[4/5] Deleting Secrets and ConfigMaps from both namespaces..."
kubectl delete -f mongo-configmap.yaml --ignore-not-found=true

echo "[5/5] Deleting namespaces..."
kubectl delete -f namespaces.yaml --ignore-not-found=true

printf "\nCleanup complete. Remaining namespaces:\n"
kubectl get namespaces

printf "\nTo stop Minikube, run: minikube stop\n"