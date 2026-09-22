# Secretless Multi-Cloud Authentication with Workload Identity

Reference implementation and reproducible evidence package for the Conf42 DevSecOps 2026 talk:

> **Secretless Multi-Cloud Authentication with Workload Identity for DevSecOps Pipelines**

## Goal

Demonstrate a DevSecOps authentication pattern where workloads use OIDC assertions and cloud workload-identity federation instead of long-lived cloud credentials.

The repository separates claims, simulations, and real measurements so experimental numbers are not presented as facts until reproduced.

## Architecture

![Secretless Multi-Cloud Architecture](docs/architecture.svg)

The architecture flow is:

**Workload → OIDC assertion → claim validation → federation → short-lived scoped access → cloud APIs → audit/provenance**

The editable diagram source is `docs/architecture.mmd`.

## Current proof scope

The reproducible implementation currently proves the pattern with **GitHub Actions OIDC → AWS IAM/STS → private S3**.

The multi-cloud architecture is the generalized design: GCP Workload Identity Federation and Microsoft Entra workload federation are shown as target patterns, but they are not represented as completed end-to-end measurements in this repository yet.

Implemented in the AWS proof:

- GitHub Actions OIDC workload identity
- AWS IAM / STS federation
- Exact issuer and audience conditions
- Exact repository + GitHub environment subject condition
- 15-minute maximum AWS role session
- Least-privilege S3 read demonstration
- Failure-closed static-key detection
- Deterministic credential-validity-window model
- Threat model and evidence plan

## Evidence roadmap

| Claim | Evidence | Status |
|---|---|---|
| No long-lived AWS key required | GitHub OIDC workflow + environment check | Ready to execute |
| Claim-scoped trust | Authorized environment + negative trust-policy tests | Ready to execute |
| Bounded credential lifetime | STS session configuration + CloudTrail | To execute |
| Exposure-window reduction | Deterministic TTL model | Reproducible |
| Token-exchange latency | Real CI p50/p95/p99 measurements | To measure |
| Failure-closed | Federation denial + no static fallback | Ready to execute |

## Credential validity-window metric

For a 365-day static credential versus a 15-minute federated credential:

`1 - 15 / (365 × 24 × 60) ≈ 99.997%`

For a 10-minute credential:

`1 - 10 / (365 × 24 × 60) ≈ 99.998%`

This is **not** a breach-probability or overall attack-surface reduction. It is specifically the reduction in credential validity window under the stated assumptions.

## Run the model

    python3 simulation/exposure_model.py

Expected output:

    15 minute token: 99.997146% shorter validity window
    10 minute token: 99.998097% shorter validity window

## AWS setup

The AWS proof creates a dedicated private S3 bucket and an IAM role in the target AWS account. No AWS access key is stored in GitHub or in this repository.

The GitHub Actions proof uses the `demo` environment. The AWS trust policy therefore authorizes the exact environment-based OIDC subject:

`repo:vvelavarthipati/secretless-multi-cloud:environment:demo`

Before running the workflow, configure these **GitHub Environment variables** under `demo`:

- `AWS_ROLE_ARN` — Terraform `role_arn` output
- `AWS_REGION` — for example `us-east-1`
- `DEMO_BUCKET` — Terraform `demo_bucket_name` output

The AWS account ID is an identifier only; it is not an authentication secret.

### Terraform

Copy `infra/aws/terraform.tfvars.example` to `infra/aws/terraform.tfvars`. The example contains only non-secret configuration. The S3 bucket used by the proof is created by Terraform.

Run:

    cd infra/aws
    terraform init
    terraform fmt -check
    terraform validate
    terraform plan

Review the plan before applying it:

    terraform apply

After apply, copy the `role_arn`, `demo_bucket_name`, and `aws_region` values into the GitHub `demo` environment variables.

### GitHub Actions

The executable proof workflow is:

`.github/workflows/aws-oidc-demo.yml`

It runs only on `main` pushes or manual dispatch and uses the `demo` environment. The workflow does not run with OIDC permissions on pull requests.

The workflow:

1. Requests an OIDC identity token.
2. Exchanges it for a short-lived AWS role session.
3. Verifies AWS identity with `aws sts get-caller-identity`.
4. Fails if a static AWS access key is present.
5. Reads the dedicated S3 bucket using the federated session.

## Negative tests

The current trust policy is environment-scoped. Negative tests should verify:

- authorized `demo` environment → allowed
- unauthorized environment subject → denied
- wrong audience → denied
- wrong repository → denied
- expired assertion → denied
- OIDC unavailable → fail closed
- static credential fallback → not configured

Branch-specific authorization is **not** claimed by the current Terraform policy because the implemented trust condition is environment-based.

## Limitations

Short-lived credentials reduce the validity window of a stolen credential. They do not prevent compromise of an authorized workload or abuse while valid.

Latency, CloudTrail correlation, failure behavior, concurrency, and production security effects require environment-specific measurements.

## Sources

- GitHub Actions OIDC for AWS: https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws
- AWS OIDC federation: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html
- AWS STS AssumeRoleWithWebIdentity: https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRoleWithWebIdentity.html
- Google Cloud Workload Identity Federation: https://cloud.google.com/iam/docs/workload-identity-federation
- Azure GitHub Actions OIDC: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect
- configure-aws-credentials: https://github.com/aws-actions/configure-aws-credentials
