#!/usr/bin/env bash

# start-mongo-app.sh
# Deploys MongoDB and Mongo-Express with PersistentVolume for data persistence

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Minikube is already running
if minikube status --format '{{.Host}}' 2>/dev/null | grep -q "Running"; then
    echo "[1/10] Minikube is already running, skipping start..."
else
    echo "[1/10] Starting Minikube..."
    minikube start
fi

echo "[2/10] Enabling Ingress addon..."
minikube addons enable ingress

echo "[3/10] Creating namespaces..."
kubectl apply -f namespaces.yaml

echo "[4/10] Applying Secrets and ConfigMaps to both namespaces..."
kubectl apply -f mongo-configmap.yaml

echo "[5/10] Applying PersistentVolumeClaim for MongoDB data..."
kubectl apply -f mongo-pvc.yaml

echo "[6/10] Applying MongoDB Deployment and Service to database-namespace..."
kubectl apply -f mongo.yaml

echo "[7/10] Waiting for MongoDB to be ready..."
kubectl rollout status deployment/mongodb-deployment -n database-namespace --timeout=300s
kubectl wait --for=condition=ready pod -l app=mongodb -n database-namespace --timeout=300s

echo "[8/10] Applying Mongo-Express Deployment and Service to app-namespace..."
kubectl apply -f mongo-express.yaml

echo "[9/10] Applying Ingress..."
kubectl apply -f ingress.yaml

echo "[10/10] Waiting for Mongo-Express to be ready..."
kubectl rollout status deployment/mongodb-express-deployment -n app-namespace --timeout=120s
kubectl wait --for=condition=ready pod -l app=mongodb-express -n app-namespace --timeout=120s

printf "\n=== Deployment Complete ===\n\n"
printf "Namespaces:\n"
kubectl get namespaces

printf "\nPersistentVolumeClaim:\n"
kubectl get pvc -n database-namespace

printf "\nIngress:\n"
kubectl get ingress -n app-namespace

printf "\nResources in app-namespace:\n"
kubectl get deployments,pods,services,ingress -n app-namespace

printf "\nResources in database-namespace:\n"
kubectl get deployments,pods,services,pvc,secrets,configmaps -n database-namespace

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
printf "      Press Ctrl+C to stop the tunnel when done.\n\n"

printf "=== Data Persistence ===\n"
printf "Your MongoDB data is now stored in a PersistentVolume.\n"
printf "The data will persist even if you:\n"
printf "  - Delete the pod\n"
printf "  - Delete the deployment\n"
printf "  - Stop and restart Minikube\n\n"
printf "To verify data persistence, create a database in Mongo-Express,\n"
printf "then run: kubectl delete pod -l app=mongodb -n database-namespace\n"
printf "The pod will be recreated and your data will remain intact.\n"