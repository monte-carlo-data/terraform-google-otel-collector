# Basic Example

This example demonstrates the basic usage of the OpenTelemetry Collector Terraform module for Google Cloud Platform.

## Usage

1. Set the required variables in `terraform.tfvars`:

```hcl
project_id      = "my-gcp-project"
deployment_name = "my-otel-collector"
region          = "us-central1"
vpc_network     = "projects/my-gcp-project/global/networks/my-vpc"
vpc_subnet      = "10.8.0.0/28"
```

2. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Variables

### Required Variables

- `project_id`: Your GCP project ID where the collector will be deployed
- `deployment_name`: Name prefix for all resources created by this module
- `region`: GCP region for Cloud Run deployment
- `vpc_network`: VPC network name or self-link for internal access

### Optional Variables

- `vpc_subnet`: Subnet CIDR range for VPC connector (e.g., '10.8.0.0/28'). Required if not using an existing VPC connector (default: null)
- `min_instances`: Minimum number of Cloud Run instances (default: 1)
- `max_instances`: Maximum number of Cloud Run instances (default: 10)
- `cpu`: CPU allocation for Cloud Run container (default: "1")
- `memory`: Memory allocation for Cloud Run container (default: "2Gi")

## Outputs

- `grpc_endpoint`: gRPC endpoint URL for sending telemetry data
- `http_endpoint`: HTTP endpoint URL for sending telemetry data
- `service_url`: Cloud Run service URL
- `service_account_email`: Email of the service account used by Cloud Run
- `vpc_connector_id`: ID of the VPC connector
- `traces_topic_name`: Name of the Pub/Sub topic for traces

## Notes

- The OpenTelemetry Collector will be deployed as an internal-only Cloud Run service.
- Telemetry data is exported to a Pub/Sub topic for further processing.
- The VPC connector allows the Cloud Run service to communicate with resources in your VPC.
- Make sure the specified VPC subnet CIDR range doesn't conflict with existing subnets.

