#!/usr/bin/env bash

# start-mongo-app.sh
# Deploys MongoDB and Mongo-Express with Ingress as the entry point.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Minikube is already running
if minikube status --format '{{.Host}}' 2>/dev/null | grep -q "Running"; then
    echo "[1/8] Minikube is already running, skipping start..."
else
    echo "[1/8] Starting Minikube..."
    minikube start
fi

echo "[2/8] Enabling Ingress addon..."
minikube addons enable ingress

echo "[3/8] Creating namespaces..."
kubectl apply -f namespaces.yaml

echo "[4/8] Applying Secrets and ConfigMaps to both namespaces..."
kubectl apply -f mongo-configmap.yaml

echo "[5/8] Applying MongoDB Deployment and Service to database-namespace..."
kubectl apply -f mongo.yaml

echo "[6/8] Waiting for MongoDB to be ready..."
kubectl rollout status deployment/mongodb-deployment -n database-namespace --timeout=300s
kubectl wait --for=condition=ready pod -l app=mongodb -n database-namespace --timeout=300s

echo "[7/8] Applying Mongo-Express Deployment and Service to app-namespace..."
kubectl apply -f mongo-express.yaml

echo "[8/8] Applying Ingress..."
kubectl apply -f ingress.yaml

echo "[9/9] Waiting for Mongo-Express to be ready..."
kubectl rollout status deployment/mongodb-express-deployment -n app-namespace --timeout=120s
kubectl wait --for=condition=ready pod -l app=mongodb-express -n app-namespace --timeout=120s

printf "\n=== Deployment Complete ===\n\n"
printf "Namespaces:\n"
kubectl get namespaces

printf "\nIngress:\n"
kubectl get ingress -n app-namespace

printf "\nResources in app-namespace:\n"
kubectl get deployments,pods,services,ingress -n app-namespace

printf "\nResources in database-namespace:\n"
kubectl get deployments,pods,services,secrets,configmaps -n database-namespace

printf "\n=== Access Instructions ===\n\n"
printf "1. Start minikube tunnel (run in a separate terminal):\n"
printf "   minikube tunnel\n\n"
printf "2. Add the following line to your /etc/hosts file:\n"
printf "   127.0.0.1 mongo.local\n\n"
printf "3. Open: https://mongo.local\n\n"
printf "   When you see 'Your connection isn't private' error:\n"
printf "   - Chrome/Edge: Click 'Advanced' -> 'Proceed to mongo.local (unsafe)'\n"
printf "   - Safari: Click 'Show Details' -> 'visit this website'\n"
printf "   - Firefox: Click 'Advanced' -> 'Accept the Risk and Continue'\n\n"
printf "Note: Keep minikube tunnel running while accessing the application.\n"
printf "      Press Ctrl+C to stop the tunnel when done.\n"