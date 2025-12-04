variable "project_id" {
  description = "GCP project ID where resources will be created"
  type        = string
}

variable "deployment_name" {
  description = "Name prefix for all resources created by this module"
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Run deployment"
  type        = string
}

variable "vpc_network" {
  description = "VPC network name or self-link for internal access"
  type        = string
}

variable "vpc_subnet" {
  description = "Subnet CIDR range for VPC connector (e.g., '10.8.0.0/28'). Required if existing_vpc_connector is not provided."
  type        = string
  default     = null
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances (0 for scale-to-zero)"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

variable "cpu" {
  description = "CPU allocation for Cloud Run container (e.g., '1' for 1 vCPU, '2' for 2 vCPUs)"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory allocation for Cloud Run container (e.g., '512Mi', '2Gi', '4Gi')"
  type        = string
  default     = "2Gi"
}
