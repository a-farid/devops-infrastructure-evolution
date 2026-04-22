# Minikube Nginx Deployment

This module demonstrates the basics of deploying a simple web application (Nginx) on Kubernetes using Minikube. It's designed for learning purposes to understand Kubernetes Deployments and Services.

## Overview

- **Deployment**: Creates 2 replicas of Nginx pods with resource limits and requests.
- **Service**: Exposes the Nginx deployment externally via a LoadBalancer service.

## Files

- `nginx-deployment.yaml`: Kubernetes Deployment manifest for Nginx pods.
- `nginx-service.yaml`: Kubernetes Service manifest to expose the deployment.

## Prerequisites

- Minikube installed and running.
- kubectl configured to use Minikube.

## Deployment Steps

1. **Start Minikube**:
   ```bash
   minikube start
   ```

2. **Apply the Deployment**:
   ```bash
   kubectl apply -f nginx-deployment.yaml
   ```

3. **Apply the Service**:
   ```bash
   kubectl apply -f nginx-service.yaml
   ```

4. **Verify the Deployment**:
   ```bash
   kubectl get pods
   kubectl get deployments
   kubectl get services
   ```

5. **Access the Application**:
   ```bash
   minikube service nginx-service --url
   ```
   This will open the Nginx welcome page in your browser.
   and the result will be as:
   %    minikube service nginx-service --url

    http://127.0.0.1:49342
    ❗  Because you are using a Docker driver on darwin, the terminal needs to be open to run it. (Minikube choses the port randomly to test the services and pods)

## Resource Configuration

The deployment includes:
- **Requests**: 250m CPU, 64Mi memory per pod
- **Limits**: 500m CPU, 128Mi memory per pod
- **Replicas**: 2

## Cleanup

To remove the resources:
```bash
kubectl delete -f nginx-service.yaml
kubectl delete -f deployment.yaml
```

## Next Steps

- Experiment with scaling: `kubectl scale deployment nginx-deployment --replicas=3`
- Update the image: Modify `deployment.yaml` and reapply.
- Add persistent storage or config maps for custom Nginx configurations.