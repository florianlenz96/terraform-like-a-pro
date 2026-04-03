variable "environment" {
  description = "Deployment stage (dev, qa, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be one of: dev, qa, prod"
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "West Europe"
}

variable "prefix" {
  description = "Short prefix to namespace all resource names (2-6 chars, lowercase)"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2,6}$", var.prefix))
    error_message = "prefix must be 2-6 lowercase letters"
  }
}

variable "tags" {
  description = "Tags applied to every resource. Must include env, owner, project."
  type        = map(string)

  validation {
    condition     = contains(keys(var.tags), "env") && contains(keys(var.tags), "owner") && contains(keys(var.tags), "project")
    error_message = "tags must include: env, owner, project"
  }
}

variable "apim_publisher_name" {
  description = "Display name for the API Management publisher"
  type        = string
  default     = "Demo Publisher"
}

variable "apim_publisher_email" {
  description = "Contact email for the API Management publisher"
  type        = string
  default     = "demo@example.com"
}
