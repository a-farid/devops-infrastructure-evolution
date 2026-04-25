#!/usr/bin/env bash

# start-mongo-app.sh
# Deploys MongoDB and Mongo-Express to separate namespaces in Minikube.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Minikube is already running
if minikube status --format '{{.Host}}' 2>/dev/null | grep -q "Running"; then
    echo "[1/7] Minikube is already running, skipping start..."
else
    echo "[1/7] Starting Minikube..."
    minikube start
fi

echo "[2/7] Creating namespaces..."
kubectl apply -f namespaces.yaml

echo "[3/7] Applying Secrets and ConfigMaps to both namespaces..."
kubectl apply -f mongo-configmap.yaml

echo "[4/7] Applying MongoDB Deployment and Service to database-namespace..."
kubectl apply -f mongo.yaml

echo "[5/7] Waiting for MongoDB to be ready..."
kubectl rollout status deployment/mongodb-deployment -n database-namespace --timeout=300s
kubectl wait --for=condition=ready pod -l app=mongodb -n database-namespace --timeout=300s

echo "[6/7] Applying Mongo-Express Deployment and Service to app-namespace..."
kubectl apply -f mongo-express.yaml

echo "[7/7] Waiting for Mongo-Express to be ready..."
kubectl rollout status deployment/mongodb-express-deployment -n app-namespace --timeout=120s
kubectl wait --for=condition=ready pod -l app=mongodb-express -n app-namespace --timeout=120s

printf "\n=== Deployment Complete ===\n\n"
printf "Namespaces:\n"
kubectl get namespaces

printf "\nResources in app-namespace:\n"
kubectl get deployments,pods,services -n app-namespace

printf "\nResources in database-namespace:\n"
kubectl get deployments,pods,services,secrets,configmaps -n database-namespace

printf "\nAccess Mongo-Express at:\n"
minikube service mongodb-express-service -n app-namespace --url

printf "\nMongoDB is accessible at: mongodb-service.database-namespace.svc.cluster.local:27017\n"