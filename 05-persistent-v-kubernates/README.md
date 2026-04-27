# Deploying MongoDB and Mongo-Express with PersistentVolume

This module demonstrates deploying a full application stack on Kubernetes with persistent storage using PersistentVolumeClaim (PVC). Data will survive pod deletions, deployments, and even Minikube restarts.

## Overview

- **app-namespace**: Hosts the Mongo-Express web UI (application tier).
- **database-namespace**: Hosts MongoDB and its configuration (database tier).
- **PersistentVolumeClaim**: 1Gi storage for MongoDB data in `/data/db`.
- **Ingress**: Entry point with TLS and HTTP→HTTPS redirect.

## Architecture

```
                              ┌─────────────────────────────────────┐
                              │           Ingress                   │
                              │   (mongo.local -> mongo-express)    │
                              │         TLS + HTTPS redirect        │
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
│  │ mongodb-pvc         │◄─────│ PersistentVolumeClaim       │ │
│  │ (/data/db)          │      │ (1Gi, standard storage)     │ │
│  └─────────────────────┘      └─────────────────────────────┘ │
│  ┌─────────────────────┐      ┌─────────────────────────────┐ │
│  │ mongodb-secret      │      │ mongodb-configmap           │ │
│  │ (Credentials)       │      │ (database_url)              │ │
│  └─────────────────────┘      └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Why PersistentVolume?

| Scenario | Without PVC | With PVC |
|----------|-------------|----------|
| Pod deleted | Data lost | Data preserved |
| Deployment updated | Data lost | Data preserved |
| Minikube restart | Data lost | Data preserved |
| Node failure | Data lost | Data preserved (if replicated) |

## Files

- `namespaces.yaml`: Defines `app-namespace` and `database-namespace`.
- `mongo-configmap.yaml`: Secrets and ConfigMaps for both namespaces + TLS secret.
- `mongo-pvc.yaml`: PersistentVolumeClaim for MongoDB data (1Gi).
- `mongo.yaml`: MongoDB Deployment with PVC volume mount + ClusterIP Service.
- `mongo-express.yaml`: Mongo-Express Deployment + ClusterIP Service.
- `ingress.yaml`: Ingress with TLS and HTTP→HTTPS redirect.
- `start-mongo-app.sh`: Deploys everything with one command.
- `cleanup-mongo-app.sh`: Removes all resources (with data loss warning).

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
5. Create PersistentVolumeClaim
6. Deploy MongoDB with PVC volume mount
7. Deploy Mongo-Express
8. Apply Ingress
9. Print access instructions

## Access the Application

After deployment, run the tunnel and add the hostname:

```bash
# Terminal 1: Start the tunnel (keep it running)
minikube tunnel

# Terminal 2: Add to /etc/hosts
echo "127.0.0.1 mongo.local" | sudo tee -a /etc/hosts

# Then open in browser (HTTPS with self-signed certificate):
open https://mongo.local
```

> **Note**: 
> - The `minikube tunnel` command must remain running while you want to access the application.
> - Since we're using a self-signed certificate, your browser will show a security warning. Accept it to proceed.
> - All HTTP traffic is automatically redirected to HTTPS.

### Accepting the Self-Signed Certificate

When you see "Your connection isn't private" error:

**Chrome/Edge:**
1. Click "Advanced" 
2. Click "Proceed to mongo.local (unsafe)"

**Safari:**
1. Click "Show Details"
2. Click "visit this website"

**Firefox:**
1. Click "Advanced"
2. Click "Accept the Risk and Continue"

## Test Data Persistence

1. Open Mongo-Express at https://mongo.local
2. Login with username: `username`, password: `password`
3. Create a database or add some data
4. Delete the MongoDB pod:
   ```bash
   kubectl delete pod -l app=mongodb -n database-namespace
   ```
5. Wait for the pod to be recreated:
   ```bash
   kubectl get pods -n database-namespace -w
   ```
6. Refresh Mongo-Express - your data should still be there!

## Verify PVC Binding

```bash
# Check PVC status
kubectl get pvc -n database-namespace

# Should show:
# NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES
# mongodb-pvc   Bound    pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx   1Gi        RWO
```

## Manual Deployment Steps

1. Create namespaces:
   ```bash
   kubectl apply -f namespaces.yaml
   ```

2. Apply ConfigMap and Secret:
   ```bash
   kubectl apply -f mongo-configmap.yaml
   ```

3. Apply PVC:
   ```bash
   kubectl apply -f mongo-pvc.yaml
   ```

4. Deploy MongoDB:
   ```bash
   kubectl apply -f mongo.yaml
   ```

5. Deploy Mongo-Express:
   ```bash
   kubectl apply -f mongo-express.yaml
   ```

6. Apply Ingress:
   ```bash
   kubectl apply -f ingress.yaml
   ```

7. Access:
   ```bash
   # Terminal 1: Start tunnel (keep running)
   minikube tunnel

   # Terminal 2: Add to /etc/hosts
   echo "127.0.0.1 mongo.local" | sudo tee -a /etc/hosts

   # Open browser (HTTPS with self-signed certificate)
   open https://mongo.local
   ```

## Resource Configuration

| Component | Namespace | Type | Storage | Requests | Limits |
|-----------|-----------|------|---------|----------|--------|
| MongoDB | database-namespace | ClusterIP | 1Gi PVC | 500m CPU, 256Mi | 1 CPU, 512Mi |
| Mongo-Express | app-namespace | ClusterIP | - | 500m CPU, 128Mi | 1 CPU, 256Mi |
| PVC | database-namespace | ReadWriteOnce | 1Gi | - | - |
| Ingress | app-namespace | Ingress | - | - | - |

## Cleanup

```bash
./cleanup-mongo-app.sh
```

> **Warning**: This will delete the PersistentVolume and ALL DATA. The script will ask for confirmation before deleting.

## How It Works

### PersistentVolumeClaim (PVC)
- Requests 1Gi of storage from the `standard` storage class
- In Minikube, this automatically creates a hostPath PersistentVolume
- The PVC binds to the PV when the deployment is created

### Volume Mount
- The MongoDB container mounts the PVC at `/data/db` (MongoDB's default data directory)
- All database files are stored on the persistent volume
- Even if the container restarts or the pod is deleted, the data remains

### Storage Class
- `standard` is the default storage class in Minikube
- Creates hostPath volumes on the Minikube node
- Suitable for development/testing

## Next Steps

- Add a second replica for high availability
- Use ReadWriteMany for multi-pod access (requires NFS or cloud storage)
- Set up regular backups of the PersistentVolume
- Explore StatefulSets for better persistent storage management