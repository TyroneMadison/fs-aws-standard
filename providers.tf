provider "aws" {
  region = var.region

  # Org-wide mandatory tags applied to EVERY taggable resource.
  # This is the safety net: even if a resource forgets a tag, these still land.
  # Directly addresses the tagging chaos in the current environment.
  default_tags {
    tags = {
      ManagedBy     = "Terraform"
      ProvisionedBy = "cloud-engineering"
      Repo          = "fs-aws-standard"
    }
  }
}
