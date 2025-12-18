# Data Sources

data "google_project" "project" {
  project_id = var.project_id
}

# Local Variables

locals {
  service_account_email = var.service_account_email != null ? var.service_account_email : google_service_account.otel_collector[0].email
  vpc_connector_id      = var.existing_vpc_connector != null ? var.existing_vpc_connector : google_vpc_access_connector.otel_connector[0].id

  # Normalize vpc_network to a full resource path
  # Handles both "my-network" and "projects/proj/global/networks/my-network"
  vpc_network_id = (
    startswith(var.vpc_network, "projects/") || startswith(var.vpc_network, "https://")
    ? var.vpc_network
    : "projects/${var.project_id}/global/networks/${var.vpc_network}"
  )

  # OTEL Collector configuration
  otel_config = yamlencode({
    extensions = {
      health_check = {
        endpoint = "0.0.0.0:13133"
        path     = "/"
      }
      otlp_encoding = {
        protocol = "otlp_json"
      }
    }
    receivers = {
      otlp = {
        protocols = {
          grpc = {
            endpoint = "0.0.0.0:${var.grpc_port}"
          }
          http = {
            endpoint = "0.0.0.0:${var.http_port}"
          }
        }
      }
    }
    processors = {
      batch = {
        timeout         = var.batch_timeout
        send_batch_size = var.batch_size
      }
      memory_limiter = {
        check_interval  = "1s"
        limit_mib       = var.memory_limit_mib
        spike_limit_mib = var.memory_spike_limit_mib
      }
    }
    exporters = {
      debug = {
        verbosity = "detailed"
      }
      googlecloudpubsub = {
        project = var.project_id
        topic   = google_pubsub_topic.otel_collector_traces_topic.id
        traces = {
          encoding = "otlp_encoding"
          attributes = {
            "ce-type"      = "org.opentelemetry.otlp.traces.v1"
            "content-type" = "application/json"
          }
        }
      }
    }
    service = {
      extensions = ["health_check", "otlp_encoding"]
      pipelines = {
        traces = {
          receivers  = ["otlp"]
          processors = ["memory_limiter", "batch"]
          exporters  = ["debug", "googlecloudpubsub"]
        }
        metrics = {
          receivers  = ["otlp"]
          processors = ["memory_limiter", "batch"]
          exporters  = ["debug"]
        }
        logs = {
          receivers  = ["otlp"]
          processors = ["memory_limiter", "batch"]
          exporters  = ["debug"]
        }
      }
    }
  })

  common_labels = merge(
    {
      managed_by = "terraform"
      module     = "terraform-google-otel-collector"
    },
    var.labels
  )
}

# Service Account for Cloud Run

resource "google_service_account" "otel_collector" {
  count = var.service_account_email == null ? 1 : 0

  project      = var.project_id
  account_id   = "${var.deployment_name}-otel"
  display_name = "OpenTelemetry Collector for ${var.deployment_name}"
  description  = "Service account for OpenTelemetry Collector Cloud Run service"
}

# VPC Access Connector

resource "google_vpc_access_connector" "otel_connector" {
  count = var.existing_vpc_connector == null ? 1 : 0

  project = var.project_id
  name    = "${var.deployment_name}-vpc"
  region  = var.region
  network = var.vpc_network

  ip_cidr_range = var.vpc_subnet

  # Use default machine type (e2-micro) and scaling settings
  min_instances = 2
  max_instances = 3
}

# Cloud Run Service

resource "google_cloud_run_v2_service" "otel_collector" {
  project  = var.project_id
  name     = "${var.deployment_name}-otel-collector"
  location = var.region

  ingress = var.ingress

  deletion_protection = var.deletion_protection

  labels = local.common_labels

  template {
    service_account = local.service_account_email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    timeout = "${var.timeout_seconds}s"

    vpc_access {
      connector = local.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.container_image

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }

      # Cloud Run v2 only supports one port, using HTTP port as primary
      # gRPC will also be available on the same port
      ports {
        name           = "http1"
        container_port = var.http_port
      }

      env {
        name  = "OTEL_CONFIG"
        value = local.otel_config
      }

      # Pass config via command line argument
      args = ["--config=env:OTEL_CONFIG"]

      startup_probe {
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 10
        failure_threshold     = 3

        http_get {
          path = "/"
          port = 13133
        }
      }

      liveness_probe {
        timeout_seconds   = 3
        period_seconds    = 30
        failure_threshold = 3

        http_get {
          path = "/"
          port = 13133
        }
      }
    }

    max_instance_request_concurrency = var.concurrency
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_vpc_access_connector.otel_connector
  ]
}

# Pub/Sub Topic for Traces

resource "google_pubsub_topic" "otel_collector_traces_topic" {
  project = var.project_id
  name    = "otel_collector_traces_topic"

  labels = local.common_labels
}

# Pub/Sub Subscription with BigQuery Write

resource "google_pubsub_subscription" "otel_collector_traces_subscription" {
  count = var.bigquery_table_id != null ? 1 : 0

  project = var.project_id
  name    = "otel_collector_traces_subscription"
  topic   = google_pubsub_topic.otel_collector_traces_topic.name

  bigquery_config {
    table               = var.bigquery_table_id
    write_metadata      = true
    use_topic_schema    = false
    use_table_schema    = false
    drop_unknown_fields = true
  }

  labels = local.common_labels

  depends_on = [
    google_pubsub_topic.otel_collector_traces_topic
  ]
}

# IAM Permission for Pub/Sub Topic Publisher

resource "google_pubsub_topic_iam_member" "otel_collector_traces_topic_publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.otel_collector_traces_topic.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${local.service_account_email}"

  depends_on = [
    google_pubsub_topic.otel_collector_traces_topic
  ]
}

# Private DNS Zone for Cloud Run

resource "google_dns_managed_zone" "run_app_zone" {
  project     = var.project_id
  name        = "${var.deployment_name}-run-app-zone"
  dns_name    = "run.app."
  description = "Private zone for Cloud Run internal access"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.vpc_network_id
    }
  }

  labels = local.common_labels
}

# A Records for Cloud Run restricted VIP

resource "google_dns_record_set" "run_app_a" {
  project      = var.project_id
  name         = "*.run.app."
  managed_zone = google_dns_managed_zone.run_app_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

# Route for Private Google Access

resource "google_compute_route" "private_google_access" {
  project          = var.project_id
  name             = "${var.deployment_name}-private-google-access"
  network          = var.vpc_network
  dest_range       = "199.36.153.8/30"
  next_hop_gateway = "default-internet-gateway"
}

