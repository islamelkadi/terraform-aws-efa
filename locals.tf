# Local values for consistent resource naming and tagging

locals {
  # Resource naming using metadata module
  efa_name = module.metadata.resource_prefix

  # Common tags
  tags = merge(
    module.metadata.security_tags,
    var.tags,
    {
      Name       = local.efa_name
      Module     = "terraform-aws-efa"
      Purpose    = "High-performance inter-node communication for ML/HPC workloads"
      EFAEnabled = "true"
    }
  )

  # User data for EFA configuration
  default_user_data = var.enable_huge_pages ? base64encode(templatefile("${path.module}/templates/user-data.sh", {
    huge_pages_count = var.huge_pages_count
  })) : null
}