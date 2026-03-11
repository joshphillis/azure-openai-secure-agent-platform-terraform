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

variable "log_analytics_id" {
  type        = string
  description = "ID of the Log Analytics workspace."
}

variable "vnet_id" {
  type        = string
  description = "ID of the virtual network."
}

variable "delegated_subnet_id" {
  type        = string
  description = "ID of the delegated subnet for Container Apps."
}
