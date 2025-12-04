terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "otel_collector" {
  source = "../../"

  project_id      = var.project_id
  deployment_name = var.deployment_name
  region          = var.region
  vpc_network     = var.vpc_network
  vpc_subnet      = var.vpc_subnet

  # Optional customizations
  min_instances = var.min_instances
  max_instances = var.max_instances
  cpu           = var.cpu
  memory        = var.memory
}

