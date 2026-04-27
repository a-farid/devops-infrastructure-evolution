# Kubernetes Cheatsheet specifications to the 

## 1. Namespace (The Room)

| Argument | Description |
|----------|-------------|
| `metadata.name` | Unique name of the namespace |
| `metadata.labels` | Labels for organization/selecting (e.g., `env: prod`) |

---

## 2. Deployment (The Manager)

| Argument | Description |
|----------|-------------|
| `replicas` | Number of Pod copies to run |
| `selector.matchLabels` | How Deployment finds its Pods |
| `template.metadata.labels` | Labels on Pods (must match selector) |
| `containers[].image` | Docker image (e.g., `mongo:latest`) |
| `containers[].ports[].containerPort` | Internal app port (e.g., `27017`) |
| `resources.requests` | Minimum CPU/RAM needed to start |
| `resources.limits` | Maximum CPU/RAM before OOMKilled |
| `containers[].env[]` | Environment variables |
| `env[].valueFrom.secretKeyRef` | Link env var to a Secret key |
| `containers[].volumeMounts` | Mount volumes into container |

---

## 3. Service (The Switchboard)

| Argument | Description |
|----------|-------------|
| `selector` | Which Pods to send traffic to (by label) |
| `type: ClusterIP` | Internal only (default) |
| `type: NodePort` | External on port 30000-32767 |
| `type: LoadBalancer` | External via cloud provider/Minikube |
| `ports[].port` | Port Service listens on |
| `ports[].targetPort` | Port on the Pod |

---

## 4. Ingress (The Gatekeeper)

| Argument | Description |
|----------|-------------|
| `annotations` | Controller instructions (e.g., `ssl-redirect: "true"`) |
| `ingressClassName` | Which controller to use (usually `nginx`) |
| `rules[].host` | Domain name (e.g., `mongo.local`) |
| `rules[].http.paths[].path` | URL path (e.g., `/`, `/api`) |
| `rules[].http.paths[].pathType` | Usually `Prefix` |
| `rules[].http.paths[].backend.service.name` | Target Service name |
| `rules[].http.paths[].backend.service.port.number` | Target Service port |
| `tls[].hosts[]` | Hostnames for TLS |
| `tls[].secretName` | Secret containing SSL cert/key |

---

## 5. Secret (Credentials)

| Argument | Description |
|----------|-------------|
| `type: Opaque` | Generic key-value secret |
| `type: kubernetes.io/tls` | TLS certificate secret |
| `data` | Base64-encoded values |

---

## 6. ConfigMap (Configuration)

| Argument | Description |
|----------|-------------|
| `data` | Plain key-value configuration |
| `binaryData` | Binary data (base64 encoded) |

---

## 7. PersistentVolumeClaim (Storage)

| Argument | Description |
|----------|-------------|
| `accessModes: ReadWriteOnce` | Single pod access |
| `accessModes: ReadWriteMany` | Multiple pods (NFS) |
| `resources.requests.storage` | Storage size (e.g., `5Gi`) |
| `storageClassName` | Storage type (`standard`, `gp2`, etc.) |

---

## Quick Reference

### Service Types
- **ClusterIP**: Internal only (default)
- **NodePort**: External on node port 30000-32767
- **LoadBalancer**: External via cloud provider
- **Ingress**: HTTP/HTTPS routing with hostname

### Cross-Namespace Communication
```
service-name.namespace.svc.cluster.local
```

### Common Annotations
```yaml
nginx.ingress.kubernetes.io/ssl-redirect: "true"  # HTTP → HTTPS
nginx.ingress.kubernetes.io/rewrite-target: /     # Path rewrite
```