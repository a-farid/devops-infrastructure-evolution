#!/usr/bin/env bash
set -euo pipefail

# Add the MongoDB repo
helm repo add mongodb https://mongodb.github.io/helm-charts
helm repo update

# Install the operator (The 'Employee' Pod)
helm install community-operator mongodb/community-operator