# Get fresh password
TOKEN=$(aws ecr get-login-password --region eu-west-3)

# Create a temporary secret file using 'cat' to inject the variable
cat <<EOF > ecr-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-registry-key
type: kubernetes.io/dockerconfigjson
stringData: # Use stringData so we don't have to manually Base64 it!
  .dockerconfigjson: |
    {
      "auths": {
        "151217935392.dkr.ecr.eu-west-3.amazonaws.com": {
          "username": "AWS",
          "password": "$TOKEN"
        }
      }
    }
EOF

kubectl apply -f ecr-secret.yaml