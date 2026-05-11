#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

AWS_REGION="${AWS_REGION:-eu-west-3}"
ECR_REGISTRY="${ECR_REGISTRY:-151217935392.dkr.ecr.${AWS_REGION}.amazonaws.com}"
SECRET_NAME="${SECRET_NAME:-my-registry-key}"
NAMESPACE="${NAMESPACE:-default}"
OUTPUT_FILE="${OUTPUT_FILE:-ecr-secret.yaml}"

# Check for required commands before proceeding
command -v aws >/dev/null 2>&1 || { echo "ERROR: aws CLI is required." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl is required." >&2; exit 1; }

echo "Refreshing ECR pull secret '$SECRET_NAME' for registry '$ECR_REGISTRY' in namespace '$NAMESPACE'..."

auth_token="$(aws ecr get-login-password --region "$AWS_REGION")"

cat <<INNER > "$OUTPUT_FILE"
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME
  namespace: $NAMESPACE
type: kubernetes.io/dockerconfigjson
stringData:
  .dockerconfigjson: |
    {
      "auths": {
        "$ECR_REGISTRY": {
          "username": "AWS",
          "password": "$auth_token"
        }
      }
    }
INNER

kubectl apply -f "$OUTPUT_FILE"
echo "Secret '$SECRET_NAME' refreshed successfully and written to '$OUTPUT_FILE'."
