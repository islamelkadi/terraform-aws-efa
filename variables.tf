# EFA (Elastic Fabric Adapter) Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the EFA resources"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# EFA-specific variables
variable "subnet_ids" {
  description = "List of subnet IDs where EFA network interfaces will be created"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "At least 1 subnet ID is required for EFA network interfaces"
  }
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to EFA network interfaces"
  type        = list(string)

  validation {
    condition     = length(var.security_group_ids) >= 1
    error_message = "At least 1 security group ID is required for EFA network interfaces"
  }
}

variable "efa_count" {
  description = "Number of EFA network interfaces to create"
  type        = number
  default     = 1

  validation {
    condition     = var.efa_count >= 1 && var.efa_count <= 32
    error_message = "EFA count must be between 1 and 32"
  }
}

variable "interface_type" {
  description = "Type of network interface (efa or efa-only)"
  type        = string
  default     = "efa"

  validation {
    condition     = contains(["efa", "efa-only"], var.interface_type)
    error_message = "Interface type must be either 'efa' or 'efa-only'"
  }
}

variable "instance_id" {
  description = "EC2 instance ID to attach EFA interfaces to (optional - for existing instances)"
  type        = string
  default     = null
}

# Launch Template Configuration (for EKS node groups)
variable "create_launch_template" {
  description = "Whether to create a launch template for EKS node groups with EFA support"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type for the launch template (must support EFA)"
  type        = string
  default     = "p5.48xlarge"
}

variable "ami_id" {
  description = "AMI ID for the launch template (if not provided, uses latest EKS optimized AMI)"
  type        = string
  default     = null
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Base64 encoded user data script for instance initialization"
  type        = string
  default     = null
}

variable "enable_huge_pages" {
  description = "Whether to enable huge pages configuration for EFA workloads"
  type        = bool
  default     = true
}

variable "huge_pages_count" {
  description = "Number of 2MiB huge pages to allocate (EFA driver pre-allocates 5128 by default)"
  type        = number
  default     = 5128
}

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module"
  type = object({
    encryption = optional(object({
      require_kms_customer_managed  = optional(bool, false)
      require_encryption_at_rest    = optional(bool, false)
      require_encryption_in_transit = optional(bool, false)
      enable_kms_key_rotation       = optional(bool, false)
    }), {})
    logging = optional(object({
      require_cloudwatch_logs = optional(bool, false)
      min_log_retention_days  = optional(number, 1)
      require_access_logging  = optional(bool, false)
      require_flow_logs       = optional(bool, false)
    }), {})
    monitoring = optional(object({
      enable_xray_tracing         = optional(bool, false)
      enable_enhanced_monitoring  = optional(bool, false)
      enable_performance_insights = optional(bool, false)
      require_cloudtrail          = optional(bool, false)
    }), {})
    network = optional(object({
      require_private_subnets = optional(bool, false)
      require_vpc_endpoints   = optional(bool, false)
      block_public_ingress    = optional(bool, false)
      require_imdsv2          = optional(bool, false)
    }), {})
    compliance = optional(object({
      enable_point_in_time_recovery = optional(bool, false)
      require_reserved_concurrency  = optional(bool, false)
      enable_deletion_protection    = optional(bool, false)
    }), {})
  })
  default = null
}

variable "security_control_overrides" {
  description = "Security control overrides with justification for audit compliance"
  type = object({
    disable_private_subnets = optional(bool, false)
    justification           = optional(string, "")
  })
  default = {
    disable_private_subnets = false
    justification           = ""
  }
}