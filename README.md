# chalkline-platform

Infrastructure and platform services for **Chalkline Athletics**.

## Environments

The same stack is configured for `dev`, `stg`, and `prod` using the files under
`environments/`. Production runs three internal services:

- `receipts-api` — accepts front-desk receipt requests
- `chalkline-storage` — writes and retrieves private objects
- `member-api` — manages gym members

`receipts-api` reaches `chalkline-storage` through private service discovery.
Only the storage task role can access the receipts bucket.

## Layout

- `*.tf` — network, ECS services, IAM, and the receipts bucket
- `environments/` — per-environment inputs

`receipts-api` and `chalkline-storage` are separate application repos. This repo is how they are deployed and which permissions each task role has.

This is a workshop repository. Read and search it; do not run `terraform apply`.
