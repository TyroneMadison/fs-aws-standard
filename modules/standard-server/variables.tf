variable "location_code" {
  type        = string
  description = "Data center code, e.g. CIN."
}

variable "environment" {
  type        = string
  description = "Environment: dev, qa, or prod."

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be one of: dev, qa, prod."
  }
}

variable "app_name" {
  type        = string
  description = "Application this server belongs to, e.g. HALO."
}

variable "server_role" {
  type        = string
  description = "Role of the server: app, web, db, or gw."

  validation {
    condition     = contains(["app", "web", "db", "gw"], var.server_role)
    error_message = "server_role must be one of: app, web, db, gw."
  }
}

variable "instance_index" {
  type        = number
  description = "Sequence number for this server: 1, 2, 3 and so on."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to launch."
}

variable "subnet_id" {
  type        = string
  description = "Subnet to place the instance in."
}

variable "vpc_id" {
  type        = string
  description = "VPC the instance lives in, used for the security group."
}

variable "instance_profile" {
  type        = string
  description = "IAM instance profile name that grants SSM management."
}

variable "owner" {
  type        = string
  description = "Owning team."
  default     = "cloud-engineering"
}

variable "enable_status_alarm" {
  type        = bool
  description = "Create a CloudWatch system status check alarm for up/down visibility."
  default     = true
}
