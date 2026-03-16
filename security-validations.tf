# Security Controls Validations
# Enforces security standards based on metadata module security controls
# Supports selective overrides with documented justification

locals {
  # Use security controls if provided, otherwise use permissive defaults
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = false
      require_encryption_at_rest    = false
      require_encryption_in_transit = false
      enable_kms_key_rotation       = false
    }
    logging = {
      require_cloudwatch_logs = false
      min_log_retention_days  = 1
      require_access_logging  = false
      require_flow_logs       = false
    }
    monitoring = {
      enable_xray_tracing         = false
      enable_enhanced_monitoring  = false
      enable_performance_insights = false
      require_cloudtrail          = false
    }
    network = {
      require_private_subnets = true # EFA workloads should use private subnets
      require_vpc_endpoints   = false
      block_public_ingress    = true
      require_imdsv2          = true
    }
    compliance = {
      enable_point_in_time_recovery = false
      require_reserved_concurrency  = false
      enable_deletion_protection    = false
    }
  }

  # Private subnet validation
  private_subnets_required = local.security_controls.network.require_private_subnets && !var.security_control_overrides.disable_private_subnets

  # Audit trail for overrides
  has_overrides          = var.security_control_overrides.disable_private_subnets
  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security Controls Check Block
check "security_controls_compliance" {
  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Please document the business reason in security_control_overrides.justification for audit compliance."
  }

  assert {
    condition     = !local.private_subnets_required || length(var.subnet_ids) > 0
    error_message = "Security control violation: EFA workloads require private subnets for security. Provide private subnet IDs or set security_control_overrides.disable_private_subnets=true with justification."
  }
}