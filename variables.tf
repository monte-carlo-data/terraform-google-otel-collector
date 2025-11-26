# Required Variables

variable "project_id" {
  description = "GCP project ID where resources will be created"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID must not be empty."
  }
}

variable "deployment_name" {
  description = "Name prefix for all resources created by this module (max 20 chars due to VPC connector name limits)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,18}[a-z0-9]$", var.deployment_name))
    error_message = "Deployment name must be 1-20 chars: lowercase, numbers, hyphens, start with letter."
  }
}

variable "region" {
  description = "GCP region for Cloud Run deployment"
  type        = string

  validation {
    condition     = length(var.region) > 0
    error_message = "Region must not be empty."
  }
}

variable "vpc_network" {
  description = "VPC network name or self-link for internal access"
  type        = string

  validation {
    condition     = length(var.vpc_network) > 0
    error_message = "VPC network must not be empty."
  }
}

variable "vpc_subnet" {
  description = "Subnet CIDR range for VPC connector (e.g., '10.8.0.0/28'). Required if existing_vpc_connector is not provided."
  type        = string
  default     = null
}

# Optional Variables - VPC Configuration

variable "existing_vpc_connector" {
  description = "ID of an existing VPC connector to use. If not provided, a new connector will be created."
  type        = string
  default     = null
}

# Optional Variables - Container Configuration

variable "container_image" {
  description = "Docker image for the OpenTelemetry Collector"
  type        = string
  default     = "otel/opentelemetry-collector-contrib:latest"
}

variable "grpc_port" {
  description = "Port for OTLP gRPC receiver"
  type        = number
  default     = 4317

  validation {
    condition     = var.grpc_port > 0 && var.grpc_port < 65536
    error_message = "gRPC port must be between 1 and 65535."
  }
}

variable "http_port" {
  description = "Port for OTLP HTTP receiver"
  type        = number
  default     = 4318

  validation {
    condition     = var.http_port > 0 && var.http_port < 65536
    error_message = "HTTP port must be between 1 and 65535."
  }
}

# Optional Variables - Cloud Run Configuration

variable "min_instances" {
  description = "Minimum number of Cloud Run instances (0 for scale-to-zero)"
  type        = number
  default     = 1

  validation {
    condition     = var.min_instances >= 0
    error_message = "Minimum instances must be >= 0."
  }
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10

  validation {
    condition     = var.max_instances > 0
    error_message = "Maximum instances must be > 0."
  }
}

variable "cpu" {
  description = "CPU allocation for Cloud Run container (e.g., '1' for 1 vCPU, '2' for 2 vCPUs)"
  type        = string
  default     = "1"

  validation {
    condition     = contains(["1", "2", "4", "8"], var.cpu)
    error_message = "CPU must be one of: 1, 2, 4, 8."
  }
}

variable "memory" {
  description = "Memory allocation for Cloud Run container (e.g., '512Mi', '2Gi', '4Gi')"
  type        = string
  default     = "2Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.memory))
    error_message = "Memory must be in format like '512Mi' or '2Gi'."
  }
}

variable "timeout_seconds" {
  description = "Request timeout in seconds (max 3600 for Cloud Run 2nd gen)"
  type        = number
  default     = 300

  validation {
    condition     = var.timeout_seconds > 0 && var.timeout_seconds <= 3600
    error_message = "Timeout must be between 1 and 3600 seconds."
  }
}

variable "concurrency" {
  description = "Maximum number of concurrent requests per Cloud Run instance"
  type        = number
  default     = 80

  validation {
    condition     = var.concurrency > 0
    error_message = "Concurrency must be > 0."
  }
}

# Optional Variables - OTEL Configuration

variable "batch_timeout" {
  description = "Batch processor timeout (e.g., '10s', '1m')"
  type        = string
  default     = "10s"

  validation {
    condition     = can(regex("^[0-9]+(s|m|h)$", var.batch_timeout))
    error_message = "Batch timeout must be in format like '10s', '1m', or '1h'."
  }
}

variable "batch_size" {
  description = "Batch processor send_batch_size"
  type        = number
  default     = 1024

  validation {
    condition     = var.batch_size > 0
    error_message = "Batch size must be > 0."
  }
}

variable "memory_limit_mib" {
  description = "Memory limiter limit in MiB"
  type        = number
  default     = 1500

  validation {
    condition     = var.memory_limit_mib > 0
    error_message = "Memory limit must be > 0."
  }
}

variable "memory_spike_limit_mib" {
  description = "Memory limiter spike limit in MiB"
  type        = number
  default     = 512

  validation {
    condition     = var.memory_spike_limit_mib > 0
    error_message = "Memory spike limit must be > 0."
  }
}

# Optional Variables - Service Account

variable "service_account_email" {
  description = "Email of an existing service account to use for Cloud Run and Pub/Sub publisher permissions. If not provided, a new service account will be created."
  type        = string
  default     = null
}

# Optional Variables - Labels

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# Optional Variables - Protection

variable "deletion_protection" {
  description = "Enable deletion protection for Cloud Run service (recommended for production)"
  type        = bool
  default     = true
}

variable "bigquery_table_id" {
  description = "BigQuery table ID for Pub/Sub subscription to write to (format: project.dataset.table or dataset.table)"
  type        = string
  default     = null
}

