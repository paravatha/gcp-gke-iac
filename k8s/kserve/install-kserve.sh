#!/bin/bash
set -euo pipefail

KNATIVE_VERSION="v1.18.0"
ISTIO_VERSION="v1.18.0"
CERT_MANAGER_VERSION="v1.18.0"
KSERVE_VERSION="v0.15.2"

echo "Applying Knative Serving CRDs..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-crds.yaml

echo "Applying Knative Serving Core..."
kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-core.yaml

helm repo update

echo "Installing Istio..."
#helm upgrade --install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-${ISTIO_VERSION}/istio.yaml
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-${ISTIO_VERSION}/net-istio.yaml
kubectl patch deployment istiod -n istio-system --type='merge' -p '{"spec":{"replicas":1}}' || true
kubectl patch deployment istio-ingressgateway -n istio-system --type='merge' -p '{"spec":{"replicas":1}}' || true

echo "Installing cert-manager..."
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version ${CERT_MANAGER_VERSION} \
  --set crds.enabled=true \
  --wait

kubectl create namespace kserve
echo "Installing KServe CRDs..."
helm upgrade --install kserve-crd oci://ghcr.io/kserve/charts/kserve-crd \
  --namespace kserve \
  --version ${KSERVE_VERSION} \
  --wait

echo "Installing KServe..."
helm upgrade --install kserve oci://ghcr.io/kserve/charts/kserve \
  --namespace kserve \
  --version ${KSERVE_VERSION} \
  --wait
