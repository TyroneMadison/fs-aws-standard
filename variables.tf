variable "region" {
  description = "AWS region. us-east-2 (Ohio) is closest to the Cincinnati data center."
  type        = string
  default     = "us-east-2"
}

variable "location_code" {
  description = "Data center / location code used in the naming convention. CIN = Cincinnati."
  type        = string
  default     = "CIN"
}

variable "owner" {
  description = "Owning team for tagging."
  type        = string
  default     = "cloud-engineering"
}

variable "primary_environment" {
  description = "Which environment VPC to build in this deployment. One of dev, qa, prod."
  type        = string
  default     = "prod"
}
