resource "aws_backup_vault" "main" {
  name = "FS-${var.location_code}-VAULT-MAIN"
}

resource "aws_backup_plan" "daily" {
  name = "FS-${var.location_code}-PLAN-DAILY"

  rule {
    rule_name         = "daily-35day-retention"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = 35
    }
  }
}

# Selection is tag-driven: anything tagged BackupPlan = fs-daily is protected.
# Build a server with that tag and it is backed up automatically, no manual step.
# This is what gives Dave the across-the-board backup coverage and reporting.
resource "aws_backup_selection" "daily" {
  name         = "FS-${var.location_code}-SEL-DAILY"
  plan_id      = aws_backup_plan.daily.id
  iam_role_arn = aws_iam_role.backup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "BackupPlan"
    value = "fs-daily"
  }
}
