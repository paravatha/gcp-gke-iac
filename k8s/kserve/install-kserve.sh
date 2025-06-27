#!/bin/bash
set -euo pipefail

# Check for required tools
for cmd in kubectl helm; do
  if ! command -v $cmd &>/dev/null; then
    echo "[ERROR] $cmd is required but not installed. Exiting."
    exit 1
  fi
done

KNATIVE_VERSION="v1.18.0"
ISTIO_VERSION="v1.18.0"
CERT_MANAGER_VERSION="v1.18.0"
KSERVE_VERSION="v0.15.2"

# Install Knative Serving
echo "[INFO] Applying Knative Serving CRDs..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-crds.yaml

echo "[INFO] Applying Knative Serving Core..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-core.yaml

# Update Helm repos
echo "[INFO] Updating Helm repositories..."
helm repo add jetstack https://charts.jetstack.io || true
helm repo add kserve https://kserve.github.io/helm-charts || true
helm repo update

# Install Istio
# echo "[INFO] Installing Istio base via Helm (commented out)..."
# helm upgrade --install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace

echo "[INFO] Installing Istio..."
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-${ISTIO_VERSION}/istio.yaml
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-${ISTIO_VERSION}/net-istio.yaml
kubectl patch deployment istiod -n istio-system --type='merge' -p '{"spec":{"replicas":1}}' || true
kubectl patch deployment istio-ingressgateway -n istio-system --type='merge' -p '{"spec":{"replicas":1}}' || true

# Install cert-manager
echo "[INFO] Installing cert-manager..."
kubectl get namespace cert-manager >/dev/null 2>&1 || kubectl create namespace cert-manager
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version ${CERT_MANAGER_VERSION} \
  --set crds.enabled=true \
  --wait

# Install KServe CRDs and KServe
echo "[INFO] Ensuring 'kserve' namespace exists..."
kubectl get namespace kserve >/dev/null 2>&1 || kubectl create namespace kserve

echo "[INFO] Installing KServe CRDs..."
helm upgrade --install kserve-crd oci://ghcr.io/kserve/charts/kserve-crd \
  --namespace kserve \
  --version ${KSERVE_VERSION} \
  --wait

echo "[INFO] Installing KServe..."
helm upgrade --install kserve oci://ghcr.io/kserve/charts/kserve \
  --namespace kserve \
  --version ${KSERVE_VERSION} \
  --wait

echo "[INFO] KServe and dependencies installation complete."
