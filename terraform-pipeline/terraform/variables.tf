# ============================================================
#  variables.tf  –  All input variable declarations
# ============================================================

variable "resource_group_name" {
  description = "Name of the Azure Resource Group to create"
  type        = string
  default     = "rg-pipeline-practice"

  validation {
    condition     = length(var.resource_group_name) > 3 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 4 and 90 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
