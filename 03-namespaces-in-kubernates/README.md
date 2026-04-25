# Deploying MongoDB and Mongo-Express in Separate Namespaces

This module demonstrates deploying a full application stack on Kubernetes using separate namespaces for the application tier and database tier. It builds on the previous module by introducing Kubernetes Namespaces for better resource isolation and organization.

## Overview

- **app-namespace**: Hosts the Mongo-Express web UI (application tier).
- **database-namespace**: Hosts MongoDB and its configuration (database tier).
- **Cross-namespace communication**: Mongo-Express connects to MongoDB using the fully qualified domain name (FQDN).

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     app-namespace                               │
│  ┌─────────────────────┐      ┌─────────────────────────────┐ │
│  │ mongodb-express     │      │ mongodb-express-service     │ │
│  │ (Web UI :8081)      │──────│ (LoadBalancer)              │ │
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

## Why Use Namespaces?

1. **Isolation**: Separates application and database resources logically.
2. **Organization**: Makes it easier to manage resources in larger clusters.
3. **Access Control**: Can apply different RBAC policies per namespace.
4. **Resource Quotas**: Set limits on CPU/memory per namespace.
5. **Environment Separation**: Useful for dev/staging/prod environments.

## Files

- `namespaces.yaml`: Defines `app-namespace` and `database-namespace`.
- `mongo-configmap.yaml`: Contains Secrets and ConfigMaps for **both** namespaces:
  - `database-namespace`: MongoDB credentials and database URL
  - `app-namespace`: Mongo-Express credentials and database URL (with FQDN to reach MongoDB)
- `mongo.yaml`: MongoDB Deployment and Service in `database-namespace`.
- `mongo-express.yaml`: Mongo-Express Deployment and Service in `app-namespace`.
- `start-mongo-app.sh`: Deploys everything with one command (checks if Minikube is already running).
- `cleanup-mongo-app.sh`: Removes all resources including namespaces.

## Prerequisites

- Minikube installed and running.
- kubectl configured to use Minikube.
- Scripts marked executable: `chmod +x start-mongo-app.sh cleanup-mongo-app.sh`

## Cross-Namespace Communication

When connecting to a service in a different namespace, you must use the **Fully Qualified Domain Name (FQDN)**:

```
<service-name>.<namespace>.svc.cluster.local
```

In this setup:
- MongoDB runs in `database-namespace` with its own Secret and ConfigMap
- Mongo-Express runs in `app-namespace` with its own Secret and ConfigMap
- The ConfigMap in `app-namespace` contains `database_url: mongodb-service.database-namespace.svc.cluster.local`
- Mongo-Express reads this FQDN to connect to MongoDB across namespaces

Each namespace has its own copy of the Secret (credentials) and ConfigMap (database URL) to avoid the Kubernetes limitation of referencing resources from other namespaces in container environment variables.

## Deploy the Application

```bash
chmod +x start-mongo-app.sh cleanup-mongo-app.sh
./start-mongo-app.sh
```

The script will:
1. Start Minikube
2. Create both namespaces
3. Deploy Secrets and ConfigMap to `database-namespace`
4. Deploy MongoDB to `database-namespace`
5. Deploy Mongo-Express to `app-namespace`
6. Wait for all pods to be ready
7. Print service URLs and status

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

5. Verify:
   ```bash
   kubectl get all -n app-namespace
   kubectl get all -n database-namespace
   ```

6. Access Mongo-Express:
   ```bash
   minikube service mongodb-express-service -n app-namespace --url
   ```

## Resource Configuration

| Component | Namespace | Requests | Limits |
|-----------|-----------|----------|--------|
| MongoDB | database-namespace | 500m CPU, 256Mi | 1 CPU, 512Mi |
| Mongo-Express | app-namespace | 500m CPU, 128Mi | 1 CPU, 256Mi |

## Cleanup

```bash
./cleanup-mongo-app.sh
```

This removes all deployments, services, secrets, configmaps, and namespaces.

## Next Steps

- Add ResourceQuotas to limit resources per namespace.
- Set up NetworkPolicies to restrict traffic between namespaces.
- Use RBAC to control access to each namespace.
- Add persistent volumes for MongoDB data persistence.