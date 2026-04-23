#!/usr/bin/env bash

# start-nginx.sh
# Starts Minikube, deploys the Nginx manifests, and prints the service URL.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/5] Starting Minikube..."
minikube start

echo "[2/5] Applying Kubernetes manifests..."
kubectl apply -f nginx-deployment.yaml -f nginx-service.yaml

echo "[3/5] Waiting for the Nginx deployment to roll out..."
kubectl rollout status deployment/nginx-deployment --timeout=120s

echo "[4/5] Waiting for Nginx pods to become ready..."
kubectl wait --for=condition=ready pod -l app=nginx --timeout=120s

echo "[5/5] Deployment complete. Resource status:"
kubectl get deployments,replicasets,pods,services -l app=nginx

printf "\nAccess Nginx at:\n"
minikube service nginx-service --url
