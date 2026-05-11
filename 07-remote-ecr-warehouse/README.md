# Remote ECR Kubernetes Deployment

This folder contains a Kubernetes deployment example that pulls a private image from AWS ECR and a helper script to refresh the image pull secret before AWS ECR credentials expire.

## Files

- `deployment.yaml`
  - Kubernetes `Deployment` manifest for `my-web-app-depl`.
  - Uses `imagePullSecrets` with `my-registry-key` to authenticate to AWS ECR.
  - Deploys `151217935392.dkr.ecr.eu-west-3.amazonaws.com/my-app:1.0`.

- `generate_aws_pw.sh`
  - Bash script that fetches a fresh AWS ECR auth token and regenerates the pull secret.
  - Writes the secret to `ecr-secret.yaml` and applies it to the cluster.
  - The generated file is ignored by `.gitignore`.

- `ecr-secret.yaml`
  - Local secret template and placeholder file.
  - Actual credential data is not committed.
  - The script overwrites it with the current ECR token.

- `.gitignore`
  - Contains `ecr-secret.yaml` so the generated secret file is not tracked.

## Usage

### Prerequisites

1. `aws` CLI configured with permissions to call `aws ecr get-login-password`.
2. `kubectl` configured for the target Kubernetes cluster.

### Refresh the ECR pull secret

Run:

```bash
chmod +x generate_aws_pw.sh
./generate_aws_pw.sh
```

This does the following:

1. Reads `AWS_REGION`, `ECR_REGISTRY`, `SECRET_NAME`, and `NAMESPACE` from environment variables or uses defaults.
2. Gets a fresh ECR login password.
3. Writes a Kubernetes secret manifest to `ecr-secret.yaml`.
4. Applies the secret to the cluster.

### Environment variables

You can override defaults with:

```bash
export AWS_REGION=eu-west-3
export ECR_REGISTRY=151217935392.dkr.ecr.eu-west-3.amazonaws.com
export SECRET_NAME=my-registry-key
export NAMESPACE=default
export OUTPUT_FILE=ecr-secret.yaml
```

### Deploy the application

Apply the deployment manifest after the secret exists:

```bash
kubectl apply -f deployment.yaml
```

### Secret lifetime

AWS ECR authorization tokens expire after 12 hours, so rerun `./generate_aws_pw.sh` regularly before the token expires.

## Notes

- The Kubernetes secret and the deployment must be in the same namespace.
- If you deploy the secret to a different namespace, update both `NAMESPACE` and `deployment.yaml` accordingly.
- `ecr-secret.yaml` is intentionally ignored; the script regenerates it each time.

## Example workflow

```bash
cd 07-remote-ecr-warehouse
./generate_aws_pw.sh
kubectl apply -f deployment.yaml
```
