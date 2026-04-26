# Deploying MongoDB and Mongo-Express with Ingress

This module demonstrates deploying a full application stack on Kubernetes using separate namespaces with an Ingress controller as the entry point. It builds on the previous module by adding Ingress for external access instead of LoadBalancer services.

## Overview

- **app-namespace**: Hosts the Mongo-Express web UI (application tier).
- **database-namespace**: Hosts MongoDB and its configuration (database tier).
- **Ingress**: Acts as the entry point, routing traffic to Mongo-Express.
- **ClusterIP Services**: All services are now ClusterIP type (internal only).

## Architecture

```
                              ┌─────────────────────────────────────┐
                              │           Ingress                   │
                              │   (mongo.local -> mongo-express)    │
                              └──────────────┬──────────────────────┘
                                             │
                                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     app-namespace                               │
│  ┌─────────────────────┐      ┌─────────────────────────────┐ │
│  │ mongodb-express     │      │ mongodb-express-service     │ │
│  │ (Web UI :8081)      │◄─────│ (ClusterIP)                 │ │
│  └─────────────────────┘      └─────────────────────────────┘ │
│  ┌─────────────────────┐      ┌─────────────────────────────┐ │
│  │ mongodb-secret      │      │ mongodb-configmap           │ │
│  │ (Credentials)       │      │ (database_url)              │ │
│  └─────────────────────┘      └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Cross-namespace communication
                              │ (mongodb-service.database-namespace.svc.cluster.local)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   database-namespace                            │
│  ┌─────────────────────┐      ┌─────────────────────────────┐ │
│  │ mongodb             │      │ mongodb-service             │ │
│  │ (Database :27017)   │──────│ (ClusterIP)                 │ │
│  └─────────────────────┘      └─────────────────────────────┘ │
│  ┌─────────────────────┐      ┌─────────────────────────────┐ │
│  │ mongodb-secret      │      │ mongodb-configmap           │ │
│  │ (Credentials)       │      │ (database_url)              │ │
│  └─────────────────────┘      └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Why Use Ingress?

1. **Single Entry Point**: One URL/hostname routes to all services.
2. **Load Balancing**: Distributes traffic across pods.
3. **SSL/TLS Termination**: Can handle HTTPS.
4. **Path-based Routing**: Route different paths to different services.
5. **Cost-effective**: Works with ClusterIP services (no need for LoadBalancer).

## Files

- `namespaces.yaml`: Defines `app-namespace` and `database-namespace`.
- `mongo-configmap.yaml`: Secrets and ConfigMaps for both namespaces.
- `mongo.yaml`: MongoDB Deployment and Service (ClusterIP) in `database-namespace`.
- `mongo-express.yaml`: Mongo-Express Deployment and Service (ClusterIP) in `app-namespace`.
- `ingress.yaml`: Ingress resource routing `mongo.local` to Mongo-Express.
- `start-mongo-app.sh`: Deploys everything with one command.
- `cleanup-mongo-app.sh`: Removes all resources including namespaces.

## Prerequisites

- Minikube installed and running.
- kubectl configured to use Minikube.
- Ingress addon enabled (script handles this).
- Scripts marked executable: `chmod +x start-mongo-app.sh cleanup-mongo-app.sh`

## Deploy the Application

```bash
chmod +x start-mongo-app.sh cleanup-mongo-app.sh
./start-mongo-app.sh
```

The script will:
1. Start Minikube (or skip if already running)
2. Enable Ingress addon
3. Create both namespaces
4. Deploy Secrets and ConfigMaps to both namespaces
5. Deploy MongoDB to `database-namespace`
6. Deploy Mongo-Express to `app-namespace`
7. Apply Ingress
8. Print access instructions

## Access the Application

After deployment, you need to run `minikube tunnel` to expose the Ingress controller:

```bash
# Terminal 1: Start the tunnel (keep it running)
minikube tunnel

# Terminal 2: Add to /etc/hosts
echo "127.0.0.1 mongo.local" | sudo tee -a /etc/hosts

# Then open in browser:
open http://mongo.local
```

> **Note**: The `minikube tunnel` command must remain running while you want to access the application. It creates a tunnel to the Ingress controller. Press `Ctrl+C` to stop it when done.

## Manual Deployment Steps

1. Create namespaces:
   ```bash
   kubectl apply -f namespaces.yaml
   ```

2. Apply ConfigMap and Secret:
   ```bash
   kubectl apply -f mongo-configmap.yaml
   ```

3. Deploy MongoDB:
   ```bash
   kubectl apply -f mongo.yaml
   ```

4. Deploy Mongo-Express:
   ```bash
   kubectl apply -f mongo-express.yaml
   ```

5. Apply Ingress:
   ```bash
   kubectl apply -f ingress.yaml
   ```

6. Access:
   ```bash
   # Terminal 1: Start tunnel (keep running)
   minikube tunnel

   # Terminal 2: Add to /etc/hosts
   echo "127.0.0.1 mongo.local" | sudo tee -a /etc/hosts

   # Open browser
   open http://mongo.local
   ```

## Cross-Namespace Communication

Same as the previous module - each namespace has its own Secret and ConfigMap. The app-namespace's ConfigMap contains the FQDN to reach MongoDB:

```
mongodb-service.database-namespace.svc.cluster.local
```

## Resource Configuration

| Component | Namespace | Type | Requests | Limits |
|-----------|-----------|------|----------|--------|
| MongoDB | database-namespace | ClusterIP | 500m CPU, 256Mi | 1 CPU, 512Mi |
| Mongo-Express | app-namespace | ClusterIP | 500m CPU, 128Mi | 1 CPU, 256Mi |
| Ingress | app-namespace | Ingress | - | - |

## Cleanup

```bash
./cleanup-mongo-app.sh
```

This removes all deployments, services, ingress, secrets, configmaps, and namespaces.

## Next Steps

- Add TLS to the Ingress.
- Implement path-based routing for multiple services.
- Add health checks and readiness probes.
- Configure custom hostname with DNS.