# EFA (Elastic Fabric Adapter) Module
# Creates EFA-enabled network interfaces for high-performance inter-node communication
# in distributed ML training and HPC workloads on Amazon EKS

# Data source for EFA-supported instance types
data "aws_ec2_instance_types" "efa_supported" {
  filter {
    name   = "network-info.efa-supported"
    values = ["true"]
  }
}

# EFA Network Interface
resource "aws_network_interface" "efa" {
  count           = var.efa_count
  subnet_id       = var.subnet_ids[count.index % length(var.subnet_ids)]
  security_groups = var.security_group_ids
  interface_type  = var.interface_type

  tags = merge(local.tags, {
    Name = "${local.efa_name}-${count.index + 1}"
    Type = "EFA"
  })
}

# EFA Network Interface Attachment (if instance_id is provided)
resource "aws_network_interface_attachment" "efa" {
  count                = var.instance_id != null ? var.efa_count : 0
  instance_id          = var.instance_id
  network_interface_id = aws_network_interface.efa[count.index].id
  device_index         = count.index + 1 # Start from 1 as 0 is primary interface
}

# Data source for latest EKS optimized AMI
data "aws_ami" "eks_optimized" {
  count       = var.create_launch_template && var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Launch Template for EKS Node Groups with EFA support
resource "aws_launch_template" "efa" {
  count = var.create_launch_template ? 1 : 0

  name_prefix   = "${local.efa_name}-"
  image_id      = var.ami_id != null ? var.ami_id : data.aws_ami.eks_optimized[0].id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data != null ? var.user_data : local.default_user_data

  vpc_security_group_ids = var.security_group_ids

  # EFA network interface configuration
  dynamic "network_interfaces" {
    for_each = range(var.efa_count)
    content {
      device_index                = network_interfaces.value
      interface_type              = var.interface_type
      delete_on_termination       = true
      associate_public_ip_address = false
      security_groups             = var.security_group_ids
    }
  }

  # Instance metadata options for security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  # EBS optimization for high-performance workloads
  ebs_optimized = true

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      Name = "${local.efa_name}-instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.tags, {
      Name = "${local.efa_name}-volume"
    })
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = merge(local.tags, {
      Name = "${local.efa_name}-eni"
    })
  }

  tags = local.tags
}