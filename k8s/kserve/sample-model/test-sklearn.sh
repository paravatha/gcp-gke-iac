#!/bin/bash
set -euo pipefail

# Create namespace if it doesn't exist
echo "[INFO] Ensuring namespace 'kserve-test' exists..."
kubectl get namespace kserve-test >/dev/null 2>&1 || kubectl create namespace kserve-test

echo "[INFO] Deploying sklearn inference service..."
kubectl apply -n kserve-test -f sklearn.yaml

echo "[INFO] Waiting for inference service to be ready..."
kubectl wait --for=condition=Ready inferenceservice/sklearn-iris -n kserve-test --timeout=180s

kubectl get inferenceservices sklearn-iris -n kserve-test
kubectl get svc istio-ingressgateway -n istio-system

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

echo "INGRESS_HOST=${INGRESS_HOST}"
echo "INGRESS_PORT=${INGRESS_PORT}"

if [[ -z "${INGRESS_HOST}" ]]; then
  echo "[ERROR] Could not determine INGRESS_HOST. Exiting."
  exit 1
fi

INPUT_FILE=$(mktemp ./iris-input.XXXX.json)
cat <<EOF > "$INPUT_FILE"
{
  "instances": [
    [6.8,  2.8,  4.8,  1.4],
    [6.0,  3.4,  4.5,  1.6]
  ]
}
EOF

echo "[INFO] Input payload written to $INPUT_FILE"

SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n kserve-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
echo "SERVICE_HOSTNAME=${SERVICE_HOSTNAME}"

# Uncomment to test prediction endpoint directly
# echo "[INFO] Sending test request to model endpoint..."
# curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict -d @$INPUT_FILE

echo "[INFO] Running Vegeta load test job..."
kubectl apply -f perf-test.yaml
