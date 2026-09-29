# ============================================================
#  Practice Terraform – main.tf
#  A simple Azure Resource Group to test the pipeline end-to-end
# ============================================================

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote backend – filled by the pipeline variables
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# ── Variables ────────────────────────────────────────────────
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-pipeline-practice"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment tag (dev / staging / prod)"
  type        = string
  default     = "dev"
}

# ── Resources ─────────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Pipeline    = "ADO-4-Stage-Practice"
  }
}

# ── Outputs ───────────────────────────────────────────────────
output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}
