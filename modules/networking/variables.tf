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

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the VNet."
}

variable "subnet_cidrs" {
  type = object({
    containerapps = string
    workload      = optional(string)
  })
  description = "CIDR blocks for subnets."
}
