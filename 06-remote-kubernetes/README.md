# Remote Kubernetes on Linode

This folder shows a professional repo layout for a remote Linode Kubernetes cluster, with separate folders for scripts, manual YAML, and Helm values.

## Purpose

- `scripts/setup.sh`: One-click deployment flow for the remote Kubernetes stack.
- `k8s/`: Manual Kubernetes YAML for `mongo-express`, `Ingress`, and namespace setup.
- `helm/values-production.yaml`: Production-style Helm values for the Bitnami MongoDB chart.

## What this deployment does

1. Creates a production namespace in the cluster.
2. Installs the nginx ingress controller with `helm`.
3. Installs MongoDB using the Bitnami Helm chart.
4. Deploys `mongo-express` via a YAML manifest.
5. Creates an `Ingress` route so `mongo-express` is available in the browser.

## Prerequisites

- `kubectl` installed and configured to talk to your Linode Kubernetes cluster.
- `helm` installed.
- `linode-cli` installed if you want to create the cluster from the script.
- A Linode API token stored in `LINODE_TOKEN` or configured through `linode-cli`.
- Do not commit your `kubeconfig` or Linode API token into Git.

## How to use

1. Create or use an existing Linode Kubernetes cluster with 3 worker nodes.

   Example Linode CLI command:
   ```bash
   linode-cli lke cluster-create \
     --label my-remote-cluster \
     --region us-east \
     --k8s_version 1.28 \
     --node_pools '[{"type":"g6-standard-2","count":3,"label":"worker"}]'
   ```

2. Download the kubeconfig for the cluster and point `kubectl` to it.

   Example:
   ```bash
   linode-cli lke kubeconfig-view <cluster-id> > ~/.kube/config
   export KUBECONFIG=~/.kube/config
   ```

3. Run the setup script from this folder:

   ```bash
   bash scripts/setup.sh
   ```

4. Confirm the deployment status:

   ```bash
   kubectl get pods -n prod
   kubectl get pods -n ingress-nginx
   ```

5. Get the external IP for the nginx ingress controller:

   ```bash
   kubectl -n ingress-nginx get svc ingress-nginx-controller
   ```

6. Open `mongo-express` in your browser:

   ```text
   http://<INGRESS_EXTERNAL_IP>/mongo-express
   ```

## Notes

- The ingress is configured with path-based routing, so no DNS is required.
- The repository is intentionally organized to separate application YAML from Helm-driven infrastructure.
- Keep secrets and configuration outside Git; use `.gitignore` to protect them.
