# Monte Carlo Google OpenTelemetry Collector Module

A Terraform module that deploys Monte Carlo's OpenTelemetry Collector Service on Google Cloud Run.

## Architecture

This module creates:
- Cloud Run service running the OpenTelemetry Collector
- VPC Access Connector for internal networking
- Service account with appropriate IAM permissions
- Pub/Sub topic and subscription for trace data export from Collector
- BigQuery integration for storing trace data (optional)

## Prerequisites

- Terraform >= 1.0
- Google Cloud CLI configured with appropriate permissions
- Existing VPC network
- BigQuery dataset (optional, for storing telemetry data)

## Usage

### Basic Example

```hcl
module "otel_collector" {
  source = "monte-carlo-data/terraform-google-otel-collector"

  project_id      = "my-gcp-project"
  deployment_name = "my-otel-collector"
  region          = "us-central1"
  vpc_network     = "projects/my-gcp-project/global/networks/my-vpc"
  vpc_subnet      = "10.8.0.0/28"
}
```

### Advanced Example

```hcl
module "otel_collector" {
  source = "monte-carlo-data/terraform-google-otel-collector"

  # Required variables
  project_id      = "my-gcp-project"
  deployment_name = "production-otel"
  region          = "us-central1"
  vpc_network     = "projects/my-gcp-project/global/networks/my-vpc"

  # Use existing VPC connector
  existing_vpc_connector = "projects/my-gcp-project/locations/us-central1/connectors/my-connector"

  # Optional customizations
  min_instances = 2
  max_instances = 20
  cpu           = "2"
  memory        = "4Gi"

  # BigQuery integration
  bigquery_table_id = "my-project.my_dataset.otel_traces"

  # OTEL configuration
  batch_timeout          = "15s"
  batch_size             = 2048
  memory_limit_mib       = 3000
  memory_spike_limit_mib = 1024
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](https://developer.hashicorp.com/terraform/install) | >= 1.0 |
| <a name="requirement_google"></a> [google](https://registry.terraform.io/providers/hashicorp/google/latest) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#https://registry.terraform.io/providers/hashicorp/google/latest) | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_v2_service.otel_collector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_service_account.otel_collector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_vpc_access_connector.otel_connector](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/vpc_access_connector) | resource |
| [google_pubsub_topic.otel_collector_traces_topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_subscription.otel_collector_traces_subscription](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_project_iam_member.pubsub_publisher](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.bigquery_data_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Name prefix for all resources created by this module (max 20 chars due to VPC connector name limits) | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID where resources will be created | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region for Cloud Run deployment | `string` | n/a | yes |
| <a name="input_vpc_network"></a> [vpc\_network](#input\_vpc\_network) | VPC network name or self-link for internal access | `string` | n/a | yes |
| <a name="input_batch_size"></a> [batch\_size](#input\_batch\_size) | Batch processor send_batch_size | `number` | `1024` | no |
| <a name="input_batch_timeout"></a> [batch\_timeout](#input\_batch\_timeout) | Batch processor timeout (e.g., '10s', '1m') | `string` | `"10s"` | no |
| <a name="input_bigquery_table_id"></a> [bigquery\_table\_id](#input\_bigquery\_table\_id) | BigQuery table ID for storing telemetry data (format: project.dataset.table). If provided, creates a Pub/Sub subscription with BigQuery integration. | `string` | `null` | no |
| <a name="input_concurrency"></a> [concurrency](#input\_concurrency) | Maximum number of concurrent requests per Cloud Run instance | `number` | `80` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Docker image for the OpenTelemetry Collector | `string` | `"otel/opentelemetry-collector-contrib:latest"` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU allocation for Cloud Run container (e.g., '1' for 1 vCPU, '2' for 2 vCPUs) | `string` | `"1"` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Enable deletion protection for Cloud Run service (recommended for production) | `bool` | `true` | no |
| <a name="input_existing_vpc_connector"></a> [existing\_vpc\_connector](#input\_existing\_vpc\_connector) | ID of an existing VPC connector to use. If not provided, a new connector will be created. | `string` | `null` | no |
| <a name="input_grpc_port"></a> [grpc\_port](#input\_grpc\_port) | Port for OTLP gRPC receiver | `number` | `4317` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | Port for OTLP HTTP receiver | `number` | `4318` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | Maximum number of Cloud Run instances | `number` | `10` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory allocation for Cloud Run container (e.g., '512Mi', '2Gi', '4Gi') | `string` | `"2Gi"` | no |
| <a name="input_memory_limit_mib"></a> [memory\_limit\_mib](#input\_memory\_limit\_mib) | Memory limiter limit in MiB | `number` | `1500` | no |
| <a name="input_memory_spike_limit_mib"></a> [memory\_spike\_limit\_mib](#input\_memory\_spike\_limit\_mib) | Memory limiter spike limit in MiB | `number` | `512` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | Minimum number of Cloud Run instances (0 for scale-to-zero) | `number` | `1` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | Email of an existing service account to use for Cloud Run. If not provided, a new service account will be created. | `string` | `null` | no |
| <a name="input_timeout_seconds"></a> [timeout\_seconds](#input\_timeout\_seconds) | Request timeout in seconds (max 3600 for Cloud Run 2nd gen) | `number` | `300` | no |
| <a name="input_vpc_subnet"></a> [vpc\_subnet](#input\_vpc\_subnet) | Subnet CIDR range for VPC connector (e.g., '10.8.0.0/28'). Required if existing_vpc_connector is not provided. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_otel_collector_grpc_endpoint"></a> [otel\_collector\_grpc\_endpoint](#output\_otel\_collector\_grpc\_endpoint) | The gRPC endpoint for the OpenTelemetry Collector |
| <a name="output_otel_collector_http_endpoint"></a> [otel\_collector\_http\_endpoint](#output\_otel\_collector\_http\_endpoint) | The HTTP endpoint for the OpenTelemetry Collector |
| <a name="output_otel_collector_service_account_email"></a> [otel\_collector\_service\_account\_email](#output\_otel\_collector\_service\_account\_email) | Email of the service account used by the Cloud Run service |
| <a name="output_otel_collector_service_name"></a> [otel\_collector\_service\_name](#output\_otel\_collector\_service\_name) | Name of the Cloud Run service |
| <a name="output_otel_collector_service_url"></a> [otel\_collector\_service\_url](#output\_otel\_collector\_service\_url) | Cloud Run service URL for the OpenTelemetry Collector |
| <a name="output_otel_collector_traces_subscription_id"></a> [otel\_collector\_traces\_subscription\_id](#output\_otel\_collector\_traces\_subscription\_id) | Full ID of the Pub/Sub subscription for traces (if created) |
| <a name="output_otel_collector_traces_subscription_name"></a> [otel\_collector\_traces\_subscription\_name](#output\_otel\_collector\_traces\_subscription\_name) | Name of the Pub/Sub subscription for traces (if created) |
| <a name="output_otel_collector_traces_topic_id"></a> [otel\_collector\_traces\_topic\_id](#output\_otel\_collector\_traces\_topic\_id) | Full ID of the Pub/Sub topic for traces |
| <a name="output_otel_collector_traces_topic_name"></a> [otel\_collector\_traces\_topic\_name](#output\_otel\_collector\_traces\_topic\_name) | Name of the Pub/Sub topic for traces |
| <a name="output_otel_config"></a> [otel\_config](#output\_otel\_config) | OpenTelemetry Collector configuration (YAML) |
| <a name="output_vpc_connector_id"></a> [vpc\_connector\_id](#output\_vpc\_connector\_id) | ID of the VPC connector (if created by this module) |
| <a name="output_vpc_connector_name"></a> [vpc\_connector\_name](#output\_vpc\_connector\_name) | Name of the VPC connector (if created by this module) |

## Releases and Development

The README and basic example in the `examples/basic` directory is a good starting point to familiarize yourself with using the module.

Note that all Terraform files must conform to the standards of `terraform fmt` and the [standard module structure](https://developer.hashicorp.com/terraform/language/modules/develop).
CircleCI will sanity check formatting and for valid tf config files.
It is also recommended you use Terraform Cloud as a backend.
Otherwise, as normal, please follow Monte Carlo's code guidelines during development and review.

When ready to release simply add a new version tag, e.g. v0.0.42, and push that tag to GitHub.
See additional details [here](https://developer.hashicorp.com/terraform/registry/modules/publish#releasing-new-versions).

## License

See [LICENSE](LICENSE) for more information.

## Security

See [SECURITY](SECURITY.md) for more information.
