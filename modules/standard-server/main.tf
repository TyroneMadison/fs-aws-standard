locals {
  env_code = {
    dev  = "D"
    qa   = "Q"
    prod = "P"
  }

  # FS-<LOCATION>-<ENV>-<APP>-<ROLE>-<##>
  # Example: FS-CIN-P-HALO-APP-01
  # This is the Azure naming discipline ported into AWS. One look at the name
  # tells you site, environment, application, role, and instance number.
  name = upper(format(
    "FS-%s-%s-%s-%s-%02d",
    var.location_code,
    local.env_code[var.environment],
    var.app_name,
    var.server_role,
    var.instance_index,
  ))

  # Mandatory tag schema. These tags drive backups, patching, ownership, and
  # cost reporting. A server is not done until it carries all of them, which is
  # why they are enforced here in code instead of applied by hand after launch.
  tags = {
    Name          = local.name
    Environment   = var.environment
    Application   = var.app_name
    ServerRole    = var.server_role
    Owner         = var.owner
    BackupPlan    = "fs-daily"
    "Patch Group" = var.environment
  }
}

resource "aws_security_group" "this" {
  name        = "${local.name}-SG"
  description = "Baseline SG. No inbound. Egress only. Access via SSM Session Manager."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  iam_instance_profile   = var.instance_profile
  vpc_security_group_ids = [aws_security_group.this.id]

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "status" {
  count = var.enable_status_alarm ? 1 : 0

  alarm_name          = "${local.name}-STATUS-SYSTEM"
  alarm_description   = "System status check for ${local.name}."
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.this.id
  }
}
