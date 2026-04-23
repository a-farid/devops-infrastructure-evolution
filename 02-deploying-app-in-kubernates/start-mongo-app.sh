#!/usr/bin/env bash

# start-mongo-app.sh
# Deploys MongoDB and Mongo-Express to Minikube with one command.

set -euo pipefail # Exit on error, treat unset variables as errors, and fail on pipeline errors

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/6] Starting Minikube..."
minikube start

echo "[2/6] Applying Kubernetes Secrets and ConfigMaps..."
kubectl apply -f mongo-secret.yaml -f mongo-configmap.yaml

echo "[3/6] Applying MongoDB Deployment and Service..."
kubectl apply -f mongo.yaml

echo "[4/6] Waiting for MongoDB to be ready..."
kubectl rollout status deployment/mongodb-deployment --timeout=300s
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=300s

echo "[5/6] Applying Mongo-Express Deployment and Service..."
kubectl apply -f mongo-express.yaml

echo "[6/6] Waiting for Mongo-Express to be ready..."
kubectl rollout status deployment/mongodb-express-deployment --timeout=120s
kubectl wait --for=condition=ready pod -l app=mongodb-express --timeout=120s

printf "\nDeployment complete. Resource status:\n"
kubectl get deployments,replicasets,pods,services,secrets,configmaps

printf "\nAccess Mongo-Express at:\n"
minikube service mongodb-express-service --url

printf "\nMongoDB is accessible internally at mongodb-service:27017\n"