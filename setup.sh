#!/bin/bash

# Usage: ./setup.sh <project_id>
if [ -z "$1" ]; then
  echo "Usage: $0 <project_id>"
  exit 1
fi

PROJECT_ID="$1"

gcloud auth application-default login
gcloud auth application-default set-quota-project "$PROJECT_ID"

gcloud config set project "$PROJECT_ID"
gcloud services enable container.googleapis.com

tfinit
tfp -var-file=dev.tfvars
tfa -var-file=dev.tfvars

gcloud container clusters list

gcloud container clusters get-credentials mlops-gke-dev --region us-central1 --project "$PROJECT_ID"
