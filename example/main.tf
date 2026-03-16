# EFA Example Configuration
# Demonstrates EFA network interfaces and launch template for distributed ML training

# Data sources for VPC and subnets (assuming existing infrastructure)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Security Group for EFA workloads
resource "aws_security_group" "efa" {
  name_prefix = "${var.namespace}-${var.environment}-${var.name}-efa-"
  description = "Security group for EFA-enabled ML training instances"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
    description = "All TCP traffic within VPC for inter-node communication"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
    description = "All UDP traffic within VPC for EFA communication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.namespace}-${var.environment}-${var.name}-efa-sg"
  })
}

# EFA Module - Launch Template for EKS Node Groups
module "efa" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.efa.id]

  # Launch template for EKS node groups
  create_launch_template = true
  instance_type          = var.instance_type
  efa_count             = var.efa_count
  interface_type        = var.interface_type

  # Huge pages configuration for EFA workloads
  enable_huge_pages = true
  huge_pages_count  = var.huge_pages_count

  tags = var.tags
}