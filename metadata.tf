# Metadata Module Integration
# Provides consistent naming, tagging, and security controls

module "metadata" {
  source = "github.com/islamelkadi/terraform-aws-metadata?ref=v1.1.1"

  namespace     = var.namespace
  environment   = var.environment
  project_name  = var.name
  region        = var.region
  resource_type = "efa"
}