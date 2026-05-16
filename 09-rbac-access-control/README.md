# Kubernetes RBAC Study: MongoDB + Mongo Express

This folder demonstrates Kubernetes RBAC by deploying a MongoDB stack, a `mongo-express` frontend, and a restricted service account that can only observe pods and services.

## Files

- `environement.yaml`
  - Creates the `study-space` namespace.
  - Creates the restricted `ServiceAccount` named `user-app`.
  - Creates MongoDB root credentials in a secret.

- `mongodb.yaml`
  - Deploys MongoDB and exposes it as `mongo-service`.

- `mongo-express.yaml`
  - Deploys `mongo-express`.
  - Exposes the frontend via `mongo-express-service` and an ingress host at `mongo.local`.

- `rbac-roles.yaml`
  - Creates a `Role` that allows only `get` and `list` on `pods` and `services`.
  - Binds that role to the `user-app` service account.

- `start.sh`
  - Launches the stack in the correct order.
  - Waits for MongoDB and mongo-express readiness.

- `cleanup.sh`
  - Deletes all stack resources safely.

## How to start

```bash
cd 09-rbac-access-control
chmod +x start.sh cleanup.sh
./start.sh
```

## Ingress access

If you are using Minikube, run the tunnel in another terminal:

```bash
minikube tunnel
```

Then add the ingress host mapping:

```bash
echo "$(minikube ip) mongo.local" | sudo tee -a /etc/hosts
```

Open:

```bash
http://mongo.local
```

## Test RBAC behavior

Simulate the `user-app` service account with impersonation:

```bash
kubectl auth can-i list pods    --as=system:serviceaccount:study-space:user-app -n study-space
kubectl auth can-i get services --as=system:serviceaccount:study-space:user-app -n study-space
kubectl auth can-i delete pods  --as=system:serviceaccount:study-space:user-app -n study-space
```

Expected results:

- `list pods` → `yes`
- `get services` → `yes`
- `delete pods` → `no`

## Why this is useful

This exercise separates application deployment from access control.
The MongoDB application runs normally, while the RBAC user can only observe the cluster objects.

## Cleanup

```bash
./cleanup.sh
```
