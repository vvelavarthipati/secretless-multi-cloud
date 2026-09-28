# Reference Implementation Results

Generated from the repository's deterministic validation and credential-validity-window model.

## Validation results

| Check | Result | Evidence |
|---|---|---|
| GitHub OIDC issuer configured | PASS | Terraform IAM OIDC provider |
| Audience restricted to STS | PASS | IAM trust condition |
| Subject restricted to repository + environment | PASS | IAM trust condition |
| Maximum AWS role session | PASS | 900 seconds |
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

## What is not yet a measured result

The following require an actual AWS/GitHub execution environment and should not be presented as measured results until captured:

- OIDC token-exchange latency (p50/p95/p99)
- CloudTrail correlation and session evidence
- Negative federation tests against AWS
- Failure-closed behavior when federation is denied
- End-to-end AWS workflow success

The repository's latest AWS OIDC workflow run failed during credential configuration because the required `demo` environment variables/role configuration were not available in that run. This is an environment-readiness issue, not evidence of an authentication failure.

## Reproduction

```bash
python3 scripts/validate_reference.py
python3 simulation/exposure_model.py
```
