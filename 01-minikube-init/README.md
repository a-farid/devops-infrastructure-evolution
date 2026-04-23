# Minikube Nginx Deployment

This module demonstrates the basics of deploying a simple web application (Nginx) on Kubernetes using Minikube. It is designed for learning purposes and covers Kubernetes Deployments, Services, and a one-command startup script.

## Overview

- **Deployment**: Creates 2 replicas of Nginx pods with resource requests and limits.
- **Service**: Exposes the Nginx deployment externally through a LoadBalancer service.
- **Startup script**: A bash script to start Minikube, deploy the app, and print the service URL.

## Files

- `nginx-deployment.yaml`: Kubernetes Deployment manifest for Nginx pods.
- `nginx-service.yaml`: Kubernetes Service manifest to expose the deployment.
- `start-nginx.sh`: Bash script to start Minikube and deploy the Nginx app with one command.

## Prerequisites

- Minikube installed and running.
- kubectl configured to use the Minikube cluster.
- `start-nginx.sh` marked executable if you want to run it directly.

## Start the Nginx App

Run the startup script from this directory:
```bash
chmod +x start-nginx.sh
./start-nginx.sh
```

The script will:
- start Minikube
- apply `nginx-deployment.yaml` and `nginx-service.yaml`
- wait for the deployment and pods to become ready
- print the service URL

## Manual Deployment Steps

If you prefer to deploy manually:

1. Start Minikube:
   ```bash
   minikube start
   ```

2. Apply the deployment and service:
   ```bash
   kubectl apply -f nginx-deployment.yaml -f nginx-service.yaml
   ```

3. Verify the deployment:
   ```bash
   kubectl get pods
   kubectl get deployments
   kubectl get services
   ```

4. Access the application:
   ```bash
   minikube service nginx-service --url
   ```

## Resource Configuration

The deployment includes:
- **Requests**: 250m CPU and 64Mi memory per pod
- **Limits**: 500m CPU and 128Mi memory per pod
- **Replicas**: 2

## Cleanup

To remove the resources:
```bash
kubectl delete -f nginx-service.yaml
kubectl delete -f nginx-deployment.yaml
```

## Next Steps

- Experiment with scaling: `kubectl scale deployment nginx-deployment --replicas=3`
- Update the image: modify `nginx-deployment.yaml` and reapply.
- Add persistent storage or ConfigMaps for custom Nginx configuration.