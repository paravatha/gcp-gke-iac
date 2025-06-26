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

## Load Testing with Vegeta and KServe

This repository includes a Kubernetes Job for load testing KServe model endpoints using [Vegeta](https://github.com/tsenart/vegeta).

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
