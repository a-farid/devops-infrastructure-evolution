# Kubernetes MongoDB Operator Stack

This folder deploys a MongoDB Community operator, a MongoDB database CR, a `mongo-express` frontend, and an ingress route to expose the frontend.

## What is included

- `mongodb_setup_op.sh`
  - Adds the MongoDB Helm repository.
  - Installs the MongoDB Community operator.
  - Creates/updates the `mongo-admin-password` secret.
  - Applies `database.yaml` to create the MongoDB custom resource.

- `database.yaml`
  - Defines a `MongoDBCommunity` custom resource for a 1-member MongoDB replica set.
  - Uses SCRAM authentication and a password secret.
  - Includes a fixed `scramCredentialsSecretName` to avoid an operator secret naming error.

- `mongo-express.yaml`
  - Deploys `mongo-express` and a cluster service.
  - Connects to the MongoDB headless service `my-mongo-svc`.
  - Now explicitly sets port `27017` and auth database `admin`.

- `ingress.yaml`
  - Defines a Kubernetes `Ingress` hostname `mongo.local`.
  - Uses `ingressClassName: nginx` so an nginx ingress controller can bind it.

- `cleanup.sh`
  - Removes the operator release, MongoDB CR, mongo-express resources, ingress, and secret.

## What was wrong

### 1. MongoDB operator CR failed

The MongoDB Community custom resource was failing with:

- `could not ensure scram credentials: faild to create scram credentials secret -scram-credentials`

This happened because the operator was unable to generate a valid SCRAM credentials secret name for the user.

### Fix applied

- Added `passwordSecretRef.key: password` to the user secret reference.
- Added `scramCredentialsSecretName: admin-scram-credentials` to the user definition.

This allowed the operator to build the automation config and start the MongoDB pod.

### 2. `mongo-express` DNS/connectivity

The `mongo-express` app originally failed because MongoDB was not actually running yet and the operator CR had failed.

After the operator fix, the cluster now has:

- `my-mongo-0` pod running
- `my-mongo-svc` headless service with endpoints
- `mongo-express` deployment running

### 3. Ingress only works if an ingress controller is installed

Creating an `Ingress` object alone does not serve traffic.

You must install an ingress controller such as nginx ingress. For example:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/kind/deploy.yaml
```

If you use Minikube, enable the ingress addon instead:

```bash
minikube addons enable ingress
```

Then add a local host entry for `mongo.local`:

```bash
echo "$(minikube ip) mongo.local" | sudo tee -a /etc/hosts
```

If you are not using Minikube, map `mongo.local` to the correct cluster ingress IP.

## How to deploy

```bash
cd 08-operators-in-k8s
chmod +x mongodb_setup_op.sh
./mongodb_setup_op.sh
```

If you are using Minikube with a LoadBalancer nginx controller, run this in another terminal:

```bash
minikube tunnel
```

If you are using the Minikube ingress addon, create a host record instead:

```bash
echo "$(minikube ip) mongo.local" | sudo tee -a /etc/hosts
```

Then access:

```bash
http://mongo.local
```

## Cleanup

A cleanup script is available to remove the resources created by this setup:

```bash
chmod +x cleanup.sh
./cleanup.sh
```

## Notes

- The MongoDB service is headless, so the frontend must connect to `my-mongo-svc` on port `27017`.
- The ingress host is `mongo.local` and must be resolvable from your browser.
- `mongodb_setup_op.sh` now installs the operator, creates the secret, deploys the database, mongo-express, and ingress, and waits for readiness.
- If the site still does not open, verify the ingress controller is installed and the host entry is correct.
