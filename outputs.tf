output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "Pulled from the central CIDR registry. Guaranteed non-overlapping."
  value       = aws_vpc.main.cidr_block
}

output "server_names" {
  description = "The enforced, human-readable names of every server built."
  value = {
    app = module.app_server.name
    web = module.web_server.name
    db  = module.db_server.name
  }
}

output "patch_groups" {
  description = "Patch groups registered to the baseline."
  value       = sort([for g in aws_ssm_patch_group.env : g.patch_group])
}
