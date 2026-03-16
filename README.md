# Terraform AWS EFA (Elastic Fabric Adapter) Module

[![Terraform Security](https://github.com/islamelkadi/terraform-aws-efa/actions/workflows/terraform-security.yaml/badge.svg)](https://github.com/islamelkadi/terraform-aws-efa/actions/workflows/terraform-security.yaml)
[![Terraform Lint & Validation](https://github.com/islamelkadi/terraform-aws-efa/actions/workflows/terraform-lint.yaml/badge.svg)](https://github.com/islamelkadi/terraform-aws-efa/actions/workflows/terraform-lint.yaml)
[![Terraform Docs](https://github.com/islamelkadi/terraform-aws-efa/actions/workflows/terraform-docs.yaml/badge.svg)](https://github.com/islamelkadi/terraform-aws-efa/actions/workflows/terraform-docs.yaml)

This module creates AWS Elastic Fabric Adapter (EFA) network interfaces and launch templates for high-performance inter-node communication in distributed ML training and HPC workloads on Amazon EKS.

<!-- BEGIN_TF_DOCS -->


## Table of Contents

- [Prerequisites](#prerequisites)
- [Security](#security)
- [Features](#features)
- [Usage](#usage)
- [Requirements](#requirements)

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:
```bash
make install-dev-tools
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.

## Security

### Security Controls

This module implements security controls to comply with:
- AWS Foundational Security Best Practices (FSBP)
- CIS AWS Foundations Benchmark
- NIST 800-53 Rev 5
- NIST 800-171 Rev 2
- PCI DSS v4.0

### Implemented Controls

- **Private Subnets**: EFA interfaces are deployed in private subnets by default
- **IMDSv2**: Instance Metadata Service v2 is enforced for enhanced security
- **Security Groups**: Configurable security groups for network access control
- **EBS Optimization**: Enabled for high-performance storage access
- **Huge Pages**: Configurable huge pages for EFA workloads (5128 x 2MiB by default)

### Security Control Overrides

Security controls can be selectively overridden with documented justification:
- `disable_private_subnets`: Allow EFA interfaces in public subnets (not recommended)

## Features

- **EFA Network Interfaces**: Creates multiple EFA network interfaces for high-performance inter-node communication
- **Launch Template**: Optional launch template for EKS node groups with EFA support
- **Instance Type Validation**: Validates that specified instance types support EFA
- **Huge Pages Configuration**: Automatic huge pages setup for optimal EFA performance
- **Security Integration**: Integrates with terraform-aws-metadata for consistent security controls
- **Flexible Deployment**: Supports both standalone EFA interfaces and EKS node group integration

## Usage

### Basic EFA Network Interfaces

```hcl
module "efa" {
  source = "github.com/islamelkadi/terraform-aws-efa?ref=v1.0.0"

  namespace   = "example"
  environment = "prod"
  name        = "ml-training"
  region      = "us-west-2"

  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
  efa_count          = 4
  interface_type     = "efa"

  tags = {
    Project = "DistributedML"
    Team    = "MLOps"
  }
}
```

### EKS Node Group with EFA Launch Template

```hcl
module "efa_launch_template" {
  source = "github.com/islamelkadi/terraform-aws-efa?ref=v1.0.0"

  namespace   = "example"
  environment = "prod"
  name        = "gpu-cluster"
  region      = "us-west-2"

  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
  
  # Launch template configuration
  create_launch_template = true
  instance_type          = "p5.48xlarge"
  efa_count             = 32
  interface_type        = "efa"
  
  # Huge pages for EFA workloads
  enable_huge_pages = true
  huge_pages_count  = 5128

  tags = {
    Project = "DistributedML"
    Team    = "MLOps"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.36.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_launch_template.efa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_network_interface.efa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface_attachment.efa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_ami.eks_optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_instance_types.efa_supported](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_instance_types) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for the launch template (if not provided, uses latest EKS optimized AMI) | `string` | `null` | no |
| <a name="input_create_launch_template"></a> [create\_launch\_template](#input\_create\_launch\_template) | Whether to create a launch template for EKS node groups with EFA support | `bool` | `false` | no |
| <a name="input_efa_count"></a> [efa\_count](#input\_efa\_count) | Number of EFA network interfaces to create | `number` | `1` | no |
| <a name="input_enable_huge_pages"></a> [enable\_huge\_pages](#input\_enable\_huge\_pages) | Whether to enable huge pages configuration for EFA workloads | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_huge_pages_count"></a> [huge\_pages\_count](#input\_huge\_pages\_count) | Number of 2MiB huge pages to allocate (EFA driver pre-allocates 5128 by default) | `number` | `5128` | no |
| <a name="input_instance_id"></a> [instance\_id](#input\_instance\_id) | EC2 instance ID to attach EFA interfaces to (optional - for existing instances) | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for the launch template (must support EFA) | `string` | `"p5.48xlarge"` | no |
| <a name="input_interface_type"></a> [interface\_type](#input\_interface\_type) | Type of network interface (efa or efa-only) | `string` | `"efa"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | EC2 Key Pair name for SSH access | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the EFA resources | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Security control overrides with justification for audit compliance | <pre>object({<br/>    disable_private_subnets = optional(bool, false)<br/>    justification           = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_private_subnets": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module | <pre>object({<br/>    encryption = optional(object({<br/>      require_kms_customer_managed  = optional(bool, false)<br/>      require_encryption_at_rest    = optional(bool, false)<br/>      require_encryption_in_transit = optional(bool, false)<br/>      enable_kms_key_rotation       = optional(bool, false)<br/>    }), {})<br/>    logging = optional(object({<br/>      require_cloudwatch_logs = optional(bool, false)<br/>      min_log_retention_days  = optional(number, 1)<br/>      require_access_logging  = optional(bool, false)<br/>      require_flow_logs       = optional(bool, false)<br/>    }), {})<br/>    monitoring = optional(object({<br/>      enable_xray_tracing         = optional(bool, false)<br/>      enable_enhanced_monitoring  = optional(bool, false)<br/>      enable_performance_insights = optional(bool, false)<br/>      require_cloudtrail          = optional(bool, false)<br/>    }), {})<br/>    network = optional(object({<br/>      require_private_subnets = optional(bool, false)<br/>      require_vpc_endpoints   = optional(bool, false)<br/>      block_public_ingress    = optional(bool, false)<br/>      require_imdsv2          = optional(bool, false)<br/>    }), {})<br/>    compliance = optional(object({<br/>      enable_point_in_time_recovery = optional(bool, false)<br/>      require_reserved_concurrency  = optional(bool, false)<br/>      enable_deletion_protection    = optional(bool, false)<br/>    }), {})<br/>  })</pre> | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to EFA network interfaces | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs where EFA network interfaces will be created | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Base64 encoded user data script for instance initialization | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efa_count"></a> [efa\_count](#output\_efa\_count) | Number of EFA network interfaces created |
| <a name="output_efa_network_interface_ids"></a> [efa\_network\_interface\_ids](#output\_efa\_network\_interface\_ids) | List of EFA network interface IDs |
| <a name="output_efa_network_interface_mac_addresses"></a> [efa\_network\_interface\_mac\_addresses](#output\_efa\_network\_interface\_mac\_addresses) | List of MAC addresses for EFA network interfaces |
| <a name="output_efa_network_interface_private_ips"></a> [efa\_network\_interface\_private\_ips](#output\_efa\_network\_interface\_private\_ips) | List of private IP addresses assigned to EFA network interfaces |
| <a name="output_interface_type"></a> [interface\_type](#output\_interface\_type) | Type of EFA network interfaces created |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | ARN of the launch template (if created) |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | ID of the launch template (if created) |
| <a name="output_launch_template_latest_version"></a> [launch\_template\_latest\_version](#output\_launch\_template\_latest\_version) | Latest version of the launch template (if created) |
| <a name="output_supported_instance_types"></a> [supported\_instance\_types](#output\_supported\_instance\_types) | List of EFA-supported instance types in the current region |
<!-- END_TF_DOCS -->