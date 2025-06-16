# gcp-gke-iac
IaC (Terraform, k8s) to create GKE on GCP

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

## Notes

- The GKE version is controlled by the `gke_version_prefix` variable in `dev.tfvars`.
- Providers are configured in `providers.tf`.
- Cluster and endpoint outputs are available after apply.
