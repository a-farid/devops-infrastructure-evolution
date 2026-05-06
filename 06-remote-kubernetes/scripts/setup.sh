#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HELM_VALUES="$ROOT_DIR/helm/values-production.yaml"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl is required. Install it first."
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "ERROR: helm is required. Install it first."
  exit 1
fi

if command -v linode-cli >/dev/null 2>&1; then
  echo "INFO: linode-cli is installed. You can use it to create a Linode cluster."
else
  echo "INFO: linode-cli is not installed. The script will continue with deployments only."
fi

echo "=== 1/6 Create namespaces ==="
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

echo "=== 2/6 Add Helm repositories ==="
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

echo "=== 3/6 Install nginx ingress controller ==="
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.publishService.enabled=true \
  --set controller.service.type=LoadBalancer

echo "=== 4/6 Install MongoDB via Helm ==="
helm upgrade --install mongodb bitnami/mongodb \
  -n prod \
  -f "$HELM_VALUES"

echo "=== 5/6 Create mongo-express basic auth secret ==="
kubectl -n prod create secret generic mongo-express-basic-auth \
  --from-literal=username=admin \
  --from-literal=password=admin123 \
  --dry-run=client -o yaml | kubectl apply -f -

echo "=== 6/6 Deploy mongo-express and ingress ==="
kubectl -n prod apply -f "$ROOT_DIR/k8s/namespace.yaml"
kubectl -n prod apply -f "$ROOT_DIR/k8s/mongo-express.yaml"
kubectl -n prod apply -f "$ROOT_DIR/k8s/ingress.yaml"

kubectl -n prod rollout status deployment/mongo-express --timeout=120s
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=120s

cat <<'EOF'
Deployment complete.
Get the nginx ingress external IP with:
  kubectl -n ingress-nginx get svc ingress-nginx-controller
Then open:
  http://<EXTERNAL_IP>/mongo-express
EOF
