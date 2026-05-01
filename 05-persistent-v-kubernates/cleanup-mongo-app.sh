#!/usr/bin/env bash

# cleanup-mongo-app.sh
# Removes all resources including namespaces and persistent data

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Cleaning up MongoDB with PersistentVolume ==="
echo ""
echo "WARNING: This will delete all data stored in the PersistentVolume!"
echo "If you want to preserve your data, answer 'n' below."
echo ""

read -p "Do you want to delete the PersistentVolume and lose all data? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled. Your data is preserved."
    exit 0
fi

echo "[1/5] Deleting Ingress..."
kubectl delete -f ingress.yaml --ignore-not-found=true

echo "[2/5] Deleting Mongo-Express Deployment and Service..."
kubectl delete -f mongo-express.yaml --ignore-not-found=true

echo "[3/5] Deleting MongoDB Deployment and Service..."
kubectl delete -f mongo.yaml --ignore-not-found=true

echo "[4/5] Deleting PersistentVolumeClaim..."
kubectl delete -f mongo-pvc.yaml --ignore-not-found=true

echo "[5/5] Deleting namespaces (this also deletes Secrets and ConfigMaps)..."
kubectl delete -f namespaces.yaml --ignore-not-found=true

echo ""
echo "=== Cleanup Complete ==="
echo "All resources have been removed, including the PersistentVolume and data."