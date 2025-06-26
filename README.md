# gcp-gke-iac
IaC to create and manage GKE on GCP

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- GCP project with billing enabled

## Setup

1. **Authenticate with GCP and set up your project:**

   ```sh
   ./setup.sh <project_id>
   ```

   Replace `<project_id>` with your actual GCP project ID.

2. **Edit `dev.tfvars` as needed** to customize your cluster parameters.

## Usage

### Initialize Terraform

```sh
terraform init
```

### Plan the deployment

```sh
terraform plan -var-file=dev.tfvars
```

### Apply the deployment

```sh
terraform apply -var-file=dev.tfvars
```

### Destroy the deployment

```sh
terraform destroy -var-file=dev.tfvars
```

## Setting Up KServe and Dependencies

To deploy machine learning models with KServe, you need to install several components in your Kubernetes cluster:

- **Knative Serving**: Provides serverless deployment and scaling for model inference services.
- **Istio**: Acts as the networking layer for Knative, enabling advanced traffic management.
- **cert-manager**: Manages certificates for secure communication.
- **KServe**: The core framework for serving ML models on Kubernetes.

A helper script is provided to automate the installation of these components:

```sh
cd k8s/kserve
./install-kserve.sh
```

This script will:
- Install Knative Serving CRDs and core components
- Install Istio and configure it for Knative
- Install cert-manager using Helm
- Create the `kserve` namespace
- Install KServe CRDs and KServe itself using Helm

You can review or modify the script at `k8s/kserve/install-kserve.sh`.

## Load Testing KServe with Vegeta 

This repository includes a Kubernetes Job for load testing KServe model endpoints using [Vegeta](https://github.com/tsenart/vegeta).

- Deploy the Kserve sample model `k8s/kserve/sample-model/sklearn.yaml`
- The load test job is defined in `k8s/kserve/perf-test.yaml`.
- It uses a container running Vegeta to send POST requests to the `sklearn-iris` model endpoint deployed via KServe.
- The test parameters (duration, rate, CPUs) and request payload are configurable in the ConfigMap within the same YAML file.
- To run the load test, apply the manifest to your cluster:

  ```sh
  kubectl apply -f k8s/kserve/perf-test.yaml
  ```

- The job will generate a text report summarizing the performance of the model endpoint.
- You can modify the target endpoint or payload by editing the `cfg` and `payload` sections in the ConfigMap.

## Notes

- The GKE version is controlled by the `gke_version_prefix` variable in `dev.tfvars`.
- Providers are configured in `providers.tf`.
- Cluster and endpoint outputs are available after apply.
