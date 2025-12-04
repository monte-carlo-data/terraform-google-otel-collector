output "grpc_endpoint" {
  description = "The gRPC endpoint for the OpenTelemetry Collector"
  value       = module.otel_collector.otel_collector_grpc_endpoint
}

output "http_endpoint" {
  description = "The HTTP endpoint for the OpenTelemetry Collector"
  value       = module.otel_collector.otel_collector_http_endpoint
}

output "service_url" {
  description = "The Cloud Run service URL for the OpenTelemetry Collector"
  value       = module.otel_collector.otel_collector_service_url
}

output "service_account_email" {
  description = "Email of the service account used by the Cloud Run service"
  value       = module.otel_collector.otel_collector_service_account_email
}

output "vpc_connector_id" {
  description = "ID of the VPC connector"
  value       = module.otel_collector.vpc_connector_id
}

output "traces_topic_name" {
  description = "Name of the Pub/Sub topic for traces"
  value       = module.otel_collector.otel_collector_traces_topic_name
}

