# Each of these blocks is the ENTIRE thing a ticket needs.
# A request comes in for a new server, you add one block, plan, apply.
# The server comes out named to standard, fully tagged, in the right patch
# group, selected for backup, and monitored. No click-ops, no missed tags.

module "app_server" {
  source = "./modules/standard-server"

  location_code    = var.location_code
  environment      = var.primary_environment
  app_name         = "HALO"
  server_role      = "app"
  instance_index   = 1
  instance_type    = "t3.micro"
  ami_id           = data.aws_ssm_parameter.al2023.value
  subnet_id        = aws_subnet.public.id
  vpc_id           = aws_vpc.main.id
  instance_profile = aws_iam_instance_profile.ssm_instance.name
  owner            = var.owner
}

module "web_server" {
  source = "./modules/standard-server"

  location_code    = var.location_code
  environment      = var.primary_environment
  app_name         = "HALO"
  server_role      = "web"
  instance_index   = 1
  instance_type    = "t3.micro"
  ami_id           = data.aws_ssm_parameter.al2023.value
  subnet_id        = aws_subnet.public.id
  vpc_id           = aws_vpc.main.id
  instance_profile = aws_iam_instance_profile.ssm_instance.name
  owner            = var.owner
}

module "db_server" {
  source = "./modules/standard-server"

  location_code    = var.location_code
  environment      = var.primary_environment
  app_name         = "HALO"
  server_role      = "db"
  instance_index   = 1
  instance_type    = "t3.micro"
  ami_id           = data.aws_ssm_parameter.al2023.value
  subnet_id        = aws_subnet.public.id
  vpc_id           = aws_vpc.main.id
  instance_profile = aws_iam_instance_profile.ssm_instance.name
  owner            = var.owner
}
