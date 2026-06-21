# ---------------------------------------------------------------------------
# EC2 instance role: lets SSM manage the instance (patching, run command,
# session manager). AmazonSSMManagedInstanceCore is the AWS-managed
# least-privilege policy for exactly this. No SSH keys, no inbound 22.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_instance" {
  name               = "FS-${var.location_code}-ROLE-SSM-INSTANCE"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance" {
  name = "FS-${var.location_code}-PROFILE-SSM-INSTANCE"
  role = aws_iam_role.ssm_instance.name
}

# ---------------------------------------------------------------------------
# Maintenance window service role: lets SSM run patch tasks on our behalf.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "ssm_mw_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_maintenance" {
  name               = "FS-${var.location_code}-ROLE-SSM-MAINTENANCE"
  assume_role_policy = data.aws_iam_policy_document.ssm_mw_assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_mw" {
  role       = aws_iam_role.ssm_maintenance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

# ---------------------------------------------------------------------------
# AWS Backup service role.
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "backup_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "FS-${var.location_code}-ROLE-BACKUP"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
