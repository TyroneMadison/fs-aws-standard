# Patch baseline for Amazon Linux 2023. Approves Security + Critical/Important
# patches after a 7 day soak so we never deploy day-zero packages blindly.
resource "aws_ssm_patch_baseline" "al2023" {
  name             = "FS-${var.location_code}-PATCH-AL2023"
  operating_system = "AMAZON_LINUX_2023"

  approval_rule {
    approve_after_days = 7
    compliance_level   = "CRITICAL"

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }
}

# Register one patch group per environment to the baseline.
# Instances join a group via the tag literally named Patch Group
# (AWS requires that exact key, the space is mandatory).
resource "aws_ssm_patch_group" "env" {
  for_each = local.patch_windows

  baseline_id = aws_ssm_patch_baseline.al2023.id
  patch_group = each.key
}

# One maintenance window per environment, each on its own schedule.
resource "aws_ssm_maintenance_window" "patch" {
  for_each = local.patch_windows

  name     = "FS-${var.location_code}-MW-PATCH-${upper(each.key)}"
  schedule = each.value
  duration = 3
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "patch" {
  for_each = local.patch_windows

  window_id     = aws_ssm_maintenance_window.patch[each.key].id
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Patch Group"
    values = [each.key]
  }
}

resource "aws_ssm_maintenance_window_task" "patch" {
  for_each = local.patch_windows

  window_id        = aws_ssm_maintenance_window.patch[each.key].id
  task_arn         = "AWS-RunPatchBaseline"
  task_type        = "RUN_COMMAND"
  service_role_arn = aws_iam_role.ssm_maintenance.arn
  priority         = 1
  max_concurrency  = "50%"
  max_errors       = "25%"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch[each.key].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}
