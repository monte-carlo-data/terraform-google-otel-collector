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

# Pub/Sub Outputs

output "otel_collector_traces_topic_name" {
  description = "Name of the Pub/Sub topic for traces"
  value       = google_pubsub_topic.otel_collector_traces_topic.name
}

output "otel_collector_traces_topic_id" {
  description = "Full ID of the Pub/Sub topic for traces"
  value       = google_pubsub_topic.otel_collector_traces_topic.id
}

output "otel_collector_traces_subscription_name" {
  description = "Name of the Pub/Sub subscription for traces (if created)"
  value       = var.bigquery_table_id != null ? google_pubsub_subscription.otel_collector_traces_subscription[0].name : null
}

output "otel_collector_traces_subscription_id" {
  description = "Full ID of the Pub/Sub subscription for traces (if created)"
  value       = var.bigquery_table_id != null ? google_pubsub_subscription.otel_collector_traces_subscription[0].id : null
}

# DNS Outputs

output "dns_zone_name" {
  description = "Name of the private DNS zone for Cloud Run"
  value       = google_dns_managed_zone.run_app_zone.name
}

output "dns_zone_id" {
  description = "Full ID of the private DNS zone for Cloud Run"
  value       = google_dns_managed_zone.run_app_zone.id
}

# Route Outputs

output "private_google_access_route_name" {
  description = "Name of the route for private Google access"
  value       = google_compute_route.private_google_access.name
}

