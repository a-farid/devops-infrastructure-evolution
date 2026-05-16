#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl is required." >&2; exit 1; }

NAMESPACE="study-space"

echo "Applying environment resources..."
kubectl apply -f environement.yaml

echo "Applying MongoDB resources..."
kubectl apply -f mongodb.yaml

echo "Waiting for MongoDB pod readiness..."
kubectl wait --for=condition=Ready pod -l app=mongo -n "$NAMESPACE" --timeout=300s

echo "Applying mongo-express resources..."
kubectl apply -f mongo-express.yaml

echo "Waiting for mongo-express deployment readiness..."
kubectl rollout status deployment/mongo-express -n "$NAMESPACE" --timeout=180s

echo "Applying RBAC resources..."
kubectl apply -f rbac-roles.yaml

echo "Stack started successfully."
echo "If you use Minikube, run 'minikube tunnel' in another terminal."
echo "Then map the ingress host to the Minikube IP:"
echo "  echo \"$(minikube ip) mongo.local\" | sudo tee -a /etc/hosts"
echo "Open http://mongo.local to access mongo-express."
