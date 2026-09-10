# chalkline-platform

Infrastructure and platform services for **Chalkline Athletics**.

## Workshop

Clone this repo and read it. That is the whole setup.

You do not need Terraform, an AWS account, or cloud credentials. Do not run `terraform init`, `terraform plan`, or `terraform apply`. Nothing here is yours to change in a live account.

```bash
git clone https://github.com/madrobs/chalkline-receipts-terraform.git
```

If `git` is not installed yet, the receipts-api README has Mac install steps.

## Environments

The same stack is configured for `dev`, `stg`, and `prod` using the files under `environments/`. Production runs three internal services:

- `receipts-api` — accepts front-desk receipt requests
- `chalkline-storage` — writes and retrieves private objects
- `member-api` — manages gym members

`receipts-api` reaches `chalkline-storage` through private service discovery. Only the storage task role can access the receipts bucket.

## Layout

- `*.tf` — network, ECS services, IAM, and the receipts bucket
- `environments/` — per-environment inputs

`receipts-api` and `chalkline-storage` are separate application repos. This repo is how they are deployed and which permissions each task role has.
