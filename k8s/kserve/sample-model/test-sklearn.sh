kubectl create namespace kserve-test

kubectl apply -n kserve-test -f sklearn.yaml

kubectl get inferenceservices sklearn-iris -n kserve-test

kubectl get svc istio-ingressgateway -n istio-system

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')

echo "export INGRESS_HOST=${INGRESS_HOST}"
echo "export INGRESS_PORT=${INGRESS_PORT}"

cat <<EOF > "./iris-input.json"
{
  "instances": [
    [6.8,  2.8,  4.8,  1.4],
    [6.0,  3.4,  4.5,  1.6]
  ]
}
EOF


SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n kserve-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
echo "export SERVICE_HOSTNAME=${SERVICE_HOSTNAME}"
curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict -d @./iris-input.json


kubectl apply -f perf-test.yaml
