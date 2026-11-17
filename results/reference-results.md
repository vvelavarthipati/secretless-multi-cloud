# Reference Implementation Results

Generated from the repository's deterministic validation and credential-validity-window model, plus the live execution record below.

## Validation results

| Check | Result | Evidence |
|---|---|---|
| GitHub OIDC issuer configured | PASS | Terraform IAM OIDC provider |
| Audience restricted to STS | PASS | IAM trust condition |
| Subject restricted to repository + environment | PASS | IAM trust condition |
| Maximum AWS role session | PASS | 3600 seconds (AWS minimum); workflow requests 900-second sessions |
| Static AWS key fallback detected | PASS | GitHub Actions guard |
| STS identity proof present | PASS | `aws sts get-caller-identity` |
| Scoped S3 access proof present | PASS | `aws s3 ls` against demo bucket |
| Trust-policy template aligned | PASS | Deterministic validator |

## Credential validity-window model

The model compares a hypothetical 365-day static credential with short-lived federated sessions. It measures only the credential validity window.

| Credential lifetime | Validity-window reduction |
|---:|---:|
| 15 minutes | 99.997146% |
| 10 minutes | 99.998097% |

These values are deterministic calculations, not breach-probability estimates.

## Live execution record

On November 16, 2026, the reference implementation was provisioned and executed end to end in a real AWS account (GitHub OIDC provider, restricted IAM role, private S3 bucket, applied with the Terraform in `infra/aws/`).

| Run | Result | Evidence |
|---|---|---|
| AWS OIDC proof #11 (run 44025054143, commit a5ed185) | SUCCESS (13s) | No static credentials present (guard step passed before federation); GitHub OIDC token exchanged via `sts:AssumeRoleWithWebIdentity`; temporary 900-second session credentials issued; `aws sts get-caller-identity` returned the assumed restricted role; `aws s3 ls` listed the private demo bucket |

Account identifiers are masked in this public record; the unmasked run log is retained privately.

Two runs earlier the same evening failed safely, and each failure corrected the implementation:

- Run #9: AWS denied the role assumption because the token's subject did not match the trust policy. GitHub applies immutable (ID-based) subject claims to repositories created after July 15, 2026, so the token presented `repo:<OWNER>@<OWNER_ID>/<REPO>@<REPO_ID>:environment:demo` while the policy expected the classic name-based form. The Terraform now builds the ID-based subject when `github_owner_id` and `github_repository_id` are set.
- Run #10: federation succeeded and temporary credentials were issued, but the workflow's static-key guard — then placed after credential configuration — rejected the session credentials it had just received. The guard now runs before federation, and the identity-proof step requires a temporary (ASIA-prefixed) session credential.

## What is not yet a measured result

The following require an actual AWS/GitHub execution environment and should not be presented as measured results until captured:

- OIDC token-exchange latency (p50/p95/p99)
- CloudTrail correlation and session evidence
- Negative federation tests against AWS (one denial was observed during setup — run #9 above; a designed negative-test suite has not been run)
- Failure-closed behavior when federation is denied (observed once in run #9; not yet tested as a designed suite)

## Reproduction

```bash
python3 scripts/validate_reference.py
python3 simulation/exposure_model.py
```
