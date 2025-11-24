# Service Outputs

output "otel_collector_service_url" {
  description = "Cloud Run service URL for the OpenTelemetry Collector"
  value       = google_cloud_run_v2_service.otel_collector.uri
}

output "otel_collector_service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.otel_collector.name
}

output "otel_collector_grpc_endpoint" {
  description = "gRPC endpoint for OTLP (format: <service-url>:4317)"
  value       = "${google_cloud_run_v2_service.otel_collector.uri}:${var.grpc_port}"
}

output "otel_collector_http_endpoint" {
  description = "HTTP endpoint for OTLP (format: <service-url>:4318)"
  value       = "${google_cloud_run_v2_service.otel_collector.uri}:${var.http_port}"
}

# Service Account Outputs

output "otel_collector_service_account_email" {
  description = "Email of the service account used by the Cloud Run service"
  value       = local.service_account_email
}

# VPC Connector Outputs

output "vpc_connector_id" {
  description = "ID of the VPC connector (if created by this module)"
  value       = var.existing_vpc_connector == null ? google_vpc_access_connector.otel_connector[0].id : var.existing_vpc_connector
}

output "vpc_connector_name" {
  description = "Name of the VPC connector (if created by this module)"
  value       = var.existing_vpc_connector == null ? google_vpc_access_connector.otel_connector[0].name : null
}

# Configuration Outputs

output "otel_config" {
  description = "OpenTelemetry Collector configuration (YAML)"
  value       = local.otel_config
  sensitive   = false
}

