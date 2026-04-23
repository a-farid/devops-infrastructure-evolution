# Deploying MongoDB and Mongo-Express on Kubernetes

This module demonstrates deploying a full application stack on Kubernetes using Minikube, featuring MongoDB as the database and Mongo-Express as a web-based admin interface. It covers Kubernetes Deployments, Services, Secrets, ConfigMaps, and inter-service communication.

## Overview

- **MongoDB Deployment**: A single replica MongoDB pod with authentication enabled.
- **Mongo-Express Deployment**: A web UI for managing MongoDB databases, connected to the MongoDB service.
- **Secrets**: Stores sensitive data like MongoDB root username and password.
- **ConfigMap**: Provides configuration data, such as the database service URL.
- **Services**: Expose MongoDB and Mongo-Express internally and externally.

## Architecture

```
Mongo-Express (Web UI) <--> MongoDB (Database)
     |                           |
     v                           v
LoadBalancer Service       ClusterIP Service
```

Mongo-Express connects to MongoDB using the service name `mongodb-service`, with credentials pulled from the Secret.

## Files

- `mongo.yaml`: MongoDB Deployment and Service manifests.
- `mongo-express.yaml`: Mongo-Express Deployment and Service manifests.
- `mongo-secret.yaml`: Kubernetes Secret for MongoDB credentials (base64 encoded).
- `mongo-configmap.yaml`: ConfigMap for database URL configuration.
- `secrets.yaml.example`: Example Secret file (copy and modify for your credentials).
- `start-mongo-app.sh`: Bash script to deploy the entire stack with one command.
- `cleanup-mongo-app.sh`: Bash script to remove all resources and clean up.

## Prerequisites

- Minikube installed and running.
- kubectl configured to use Minikube.
- Scripts marked executable: `chmod +x start-mongo-app.sh cleanup-mongo-app.sh`

## Setup Credentials

Before deploying, update the credentials in `mongo-secret.yaml` or create from `secrets.yaml.example`:

1. Encode your username and password in base64:
   ```bash
   echo -n 'your-username' | base64
   echo -n 'your-password' | base64
   ```

2. Update `mongo-secret.yaml` with the encoded values.

## Deploy the Application

Use the startup script:
```bash
./start-mongo-app.sh
```

The script will:
- Start Minikube
- Apply all manifests
- Wait for deployments and pods to be ready
- Print service URLs

## Manual Deployment Steps

If you prefer manual steps:

1. Start Minikube:
   ```bash
   minikube start
   ```

2. Apply manifests:
   ```bash
   kubectl apply -f mongo-secret.yaml -f mongo-configmap.yaml -f mongo.yaml -f mongo-express.yaml
   ```

3. Verify deployments:
   ```bash
   kubectl get pods,deployments,services
   ```

4. Access Mongo-Express:
   ```bash
   minikube service mongodb-express-service --url
   ```
   Login with the credentials from the Secret.

## Resource Configuration

- **MongoDB**: Requests 500m CPU / 256Mi memory, Limits 1 CPU / 512Mi memory
- **Mongo-Express**: Requests 500m CPU / 128Mi memory, Limits 1 CPU / 256Mi memory
- **Replicas**: 1 for each deployment

## Cleanup

Use the cleanup script:
```bash
./cleanup-mongo-app.sh
```

This will delete all resources. To also stop Minikube:
```bash
minikube stop
```

## How It Works

1. **Secrets and ConfigMaps**: Provide configuration without hardcoding sensitive data.
2. **MongoDB Service**: Allows Mongo-Express to connect via DNS name `mongodb-service`.
3. **Mongo-Express**: Web interface running on port 8081, exposed via LoadBalancer.
4. **Inter-Service Communication**: Mongo-Express uses environment variables from Secret and ConfigMap to connect securely.

## Next Step

- Add persistent volumes for data persistence.