locals {
  env_code = {
    dev  = "D"
    qa   = "Q"
    prod = "P"
  }

  # -------------------------------------------------------------------------
  # CIDR REGISTRY  (single source of truth for IP allocation)
  #
  # Root cause of the overlap problem: developers each picked their own VPC
  # ranges with no central authority, so accounts collided and the primary
  # corporate network could not be peered or routed in.
  #
  # This registry IS that authority. Every environment gets ONE pre-allocated,
  # non-overlapping /16. Nothing gets created outside this map. In production
  # this is backed by AWS VPC IPAM so allocation is enforced account-wide.
  # -------------------------------------------------------------------------
  cidr_registry = {
    prod = "10.10.0.0/16"
    qa   = "10.20.0.0/16"
    dev  = "10.30.0.0/16"
  }

  subnet_cidrs = {
    prod = "10.10.1.0/24"
    qa   = "10.20.1.0/24"
    dev  = "10.30.1.0/24"
  }

  # Patch schedules per environment. Prod is never touched mid-week and each
  # tier gets its own slot. Maps to the per-environment patching schedule ask.
  patch_windows = {
    prod = "cron(0 2 ? * SUN *)"
    qa   = "cron(0 2 ? * SAT *)"
    dev  = "cron(0 20 ? * FRI *)"
  }
}
