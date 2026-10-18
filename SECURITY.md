# Security Policy

## Reporting

Do not publish credentials, exploit details, or sensitive reproduction data in a public issue. Use GitHub's private vulnerability reporting feature if enabled. Otherwise, contact the repository maintainer through a private channel listed on their GitHub profile.

Include the affected commit, impact, reproduction steps, and suggested mitigation. Do not send live secrets or customer data.

## Safe deployment

- Use a non-production cloud account for testing.
- Use short-lived OIDC federation credentials; do not create long-lived access keys for demonstrations.
- Apply least-privilege trust and permission policies.
- Review issuer, audience, subject, repository, branch, and workflow claims before trusting a workload.
- Inspect Terraform plans before applying them.
- Never apply example infrastructure to production without an independent review.

## Maturity

This repository is an evolving reference implementation. It does not provide a production security guarantee or an incident-response SLA.
