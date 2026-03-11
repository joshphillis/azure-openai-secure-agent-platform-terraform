variable "project_name" {
  type        = string
  description = "Short, lowercase platform name (e.g., 'secure-agent')."
}

variable "environment" {
  type        = string
  description = "Environment identifier (dev, prod, etc.)."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "workspace_name" {
  type        = string
  description = "Optional override for the Log Analytics workspace name."
  default     = null
}

variable "retention_in_days" {
  type        = number
  description = "Retention period for logs."
  default     = 30
}
