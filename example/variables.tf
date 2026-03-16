# Example Variables

variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Name for the EFA resources"
  type        = string
  default     = "ml-training"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type (must support EFA)"
  type        = string
  default     = "p5.48xlarge"
}

variable "efa_count" {
  description = "Number of EFA network interfaces"
  type        = number
  default     = 4
}

variable "interface_type" {
  description = "EFA interface type"
  type        = string
  default     = "efa"
}

variable "huge_pages_count" {
  description = "Number of 2MiB huge pages"
  type        = number
  default     = 5128
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Project = "DistributedML"
    Team    = "MLOps"
  }
}