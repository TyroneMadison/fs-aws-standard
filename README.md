# FS-AWS-Standard

A Terraform reference module that brings First Student's Azure naming and tagging
discipline into AWS, and makes every server build come out standardized, tagged,
patched, backed up, and monitored automatically.

Built by Tyrone Madison.

---

## The problem this solves

The AWS estate grew organically. Developers spun things up directly to get
products into production, the infrastructure team was not in the loop, and the
result is a sprawl that is hard to operate:

- VPC CIDR ranges overlap across accounts, so the corporate network cannot be
  cleanly routed or peered in.
- Server names are auto-generated instance IDs, so you cannot tell what an
  instance is by looking at it.
- There is no consistent tagging, so backups, patching, and cost tracking are
  guesswork.
- Patching and backup reporting are manual.

This module attacks the root cause: there was no standard and no automation.
It gives both.

---

## What it does

| Pain point | How this addresses it |
|---|---|
| Overlapping IP ranges | Central CIDR registry (`locals.tf`). One non-overlapping /16 per environment. Nothing is created outside it. IPAM in production. |
| Unreadable server names | Enforced naming convention in the module. Every name follows the Azure-style format. |
| Inconsistent tagging | Mandatory tag schema enforced in code, plus org-wide `default_tags` as a safety net. |
| Manual patching | SSM Patch Manager with a baseline, patch groups per environment, and a maintenance window per environment on its own schedule. |
| No backup coverage | AWS Backup vault and plan with tag-driven selection. Tag a server, it is protected. |
| No up/down visibility | CloudWatch system status alarm per instance, baked into the module. |

---

## Naming convention

`FS-<LOCATION>-<ENV>-<APP>-<ROLE>-<##>`

Example: `FS-CIN-P-HALO-APP-01`

| Segment | Meaning | Example |
|---|---|---|
| FS | First Student | FS |
| LOCATION | Data center code | CIN (Cincinnati) |
| ENV | Environment | P (prod), Q (qa), D (dev) |
| APP | Application | HALO |
| ROLE | Server role | APP, WEB, DB, GW |
| ## | Instance number | 01, 02, 03 |

This is the same logic the team already trusts in Azure, brought over to AWS.

---

## Tag schema

Every server carries these. The tags are not decoration, they drive automation:

| Tag | Purpose |
|---|---|
| Name | The enforced human-readable name |
| Environment | dev / qa / prod |
| Application | The owning app |
| ServerRole | app / web / db / gw |
| Owner | Owning team |
| BackupPlan | `fs-daily`. Drives AWS Backup selection. |
| Patch Group | Drives SSM patch group membership. Note the exact key with a space, AWS requires it. |
| ManagedBy, ProvisionedBy, Repo | Applied org-wide via provider default_tags |

---

## How patching works

1. A baseline approves Security and Critical/Important patches after a 7 day soak.
2. Each environment is registered as a patch group.
3. An instance joins a group by carrying the tag named Patch Group set to its
   environment. The module does this automatically.
4. A maintenance window per environment runs AWS-RunPatchBaseline on its own
   schedule. Prod patches Sunday 02:00, qa Saturday 02:00, dev Friday 20:00.
5. Patch compliance is reported back through SSM, automatically.

No SSH. No logging into boxes. Patching is replace-and-report, scheduled per tier.

---

## How backups work

AWS Backup runs a daily plan with 35 day retention. The selection is tag-driven:
anything tagged `BackupPlan = fs-daily` is in scope. Build a server with the
module and it is protected from the first apply. AWS Backup gives you the
across-the-board coverage view and reporting in one place.

---

## How IP overlap is prevented

`locals.tf` holds a CIDR registry: one pre-allocated, non-overlapping /16 per
environment. Every VPC pulls its range from that map and nothing is created
outside it, so two environments can never collide. This registry is the central
allocation authority that was missing. In production it is backed by AWS VPC IPAM
so the same enforcement applies org-wide and across accounts.

---

## Build a new server (the SOP)

This is the whole operation when a ticket comes in. Add one block to `servers.tf`:

```hcl
module "app_server_02" {
  source = "./modules/standard-server"

  location_code    = var.location_code
  environment      = "prod"
  app_name         = "HALO"
  server_role      = "app"
  instance_index   = 2
  ami_id           = data.aws_ssm_parameter.al2023.value
  subnet_id        = aws_subnet.public.id
  vpc_id           = aws_vpc.main.id
  instance_profile = aws_iam_instance_profile.ssm_instance.name
}
```

Then:

```bash
terraform plan
terraform apply
```

Out comes FS-CIN-P-HALO-APP-02: named to standard, fully tagged, in the prod
patch group, selected for daily backup, and monitored. Tagged and grouped
correctly every single time, because a human is not doing the tagging.

---

## Deploy

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Tear down when done:

```bash
terraform destroy
```

Costs are negligible for a short test: three t3.micro instances, a VPC, SSM, and
a backup vault. The maintenance windows and backup plan will not fire during a
quick apply-then-destroy.

---

## Production hardening (what I would add next)

This is a focused proof of the pattern. For production I would layer on:

- Private subnets with NAT for app and db tiers. Access stays via Session Manager.
- AWS VPC IPAM as the real CIDR authority across accounts.
- Remote state in S3 with DynamoDB locking, separate state per environment.
- A customer-managed KMS key on the backup vault.
- Separate AWS accounts per environment under an Organization.
- SNS notifications on the status alarms and on patch and backup failures.
- A CloudWatch agent association for memory and disk metrics to sit alongside
  Datadog.
