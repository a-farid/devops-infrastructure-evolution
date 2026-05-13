#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Configuration with default values.
NAMESPACE="${NAMESPACE:-default}"
RELEASE_NAME="${RELEASE_NAME:-community-operator}"
OPERATOR_CHART="mongodb/community-operator"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-YourSecurePassword}"
DB_RESOURCE_FILE="${DB_RESOURCE_FILE:-database.yaml}"
MONGO_EXPRESS_FILE="${MONGO_EXPRESS_FILE:-mongo-express.yaml}"
INGRESS_FILE="${INGRESS_FILE:-ingress.yaml}"
SECRET_NAME="${SECRET_NAME:-mongo-admin-password}"

# Ensure required CLI tools are installed.
command -v helm >/dev/null 2>&1 || { echo "ERROR: helm is required." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl is required." >&2; exit 1; }

# Add the MongoDB Helm repository if it does not already exist.
echo "Adding MongoDB Helm repository..."
helm repo add mongodb https://mongodb.github.io/helm-charts 2>/dev/null || true
helm repo update

# Install or upgrade the MongoDB Community operator.
echo "Installing or upgrading the MongoDB Community operator..."
helm upgrade --install "$RELEASE_NAME" "$OPERATOR_CHART" --namespace "$NAMESPACE" --create-namespace

# Wait until the operator pod is available.
echo "Waiting for MongoDB operator pod readiness..."
until kubectl get pod -n "$NAMESPACE" -l name=mongodb-kubernetes-operator >/dev/null 2>&1; do
  echo "  waiting for operator pod..."
  sleep 5
done
kubectl wait --for=condition=Ready pod -n "$NAMESPACE" -l name=mongodb-kubernetes-operator --timeout=180s

# Create or update the MongoDB admin secret.
echo "Creating or updating MongoDB admin password secret..."
kubectl create secret generic "$SECRET_NAME" --from-literal=password="$ADMIN_PASSWORD" --namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Apply the MongoDB custom resource definition for the database.
echo "Applying MongoDB custom resource..."
kubectl apply -f "$DB_RESOURCE_FILE"

# Wait for the MongoDB pod to be created and ready.
echo "Waiting for my-mongo-0 pod to appear..."
until kubectl get pod my-mongo-0 -n "$NAMESPACE" >/dev/null 2>&1; do
  echo "  waiting for my-mongo-0 pod..."
  sleep 5
done
kubectl wait pod/my-mongo-0 -n "$NAMESPACE" --for=condition=Ready --timeout=300s

# Deploy mongo-express and wait for it to be ready.
echo "Deploying mongo-express frontend..."
kubectl apply -f "$MONGO_EXPRESS_FILE"

echo "Waiting for mongo-express deployment readiness..."
kubectl rollout status deployment/mongo-express -n "$NAMESPACE" --timeout=180s

# Apply ingress so the app is reachable from the browser.
echo "Applying ingress resource..."
kubectl apply -f "$INGRESS_FILE"

echo "Setup complete."
echo "If you are using a LoadBalancer-based ingress controller on Minikube, run 'minikube tunnel' in another terminal."
echo "If you are using the Minikube ingress addon, ensure 'mongo.local' resolves to the ingress address."
