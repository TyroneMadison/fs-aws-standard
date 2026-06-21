# Latest Amazon Linux 2023 AMI, pulled live from SSM so it is never stale.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = local.cidr_registry[var.primary_environment]
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = upper("FS-${var.location_code}-${local.env_code[var.primary_environment]}-VPC")
    Environment = var.primary_environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = upper("FS-${var.location_code}-${local.env_code[var.primary_environment]}-IGW")
    Environment = var.primary_environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidrs[var.primary_environment]
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = upper("FS-${var.location_code}-${local.env_code[var.primary_environment]}-SNET-PUB-01")
    Environment = var.primary_environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = upper("FS-${var.location_code}-${local.env_code[var.primary_environment]}-RT-PUB")
    Environment = var.primary_environment
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
