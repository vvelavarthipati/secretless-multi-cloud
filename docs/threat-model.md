# Threat Model

## Assets
- Cloud API access
- Deployment privileges
- CI/CD release permissions
- Data and compute resources

## Threats
1. Theft of long-lived cloud credentials.
2. Replay of a stolen short-lived assertion or federated credential.
3. Over-broad OIDC trust policies.
4. Compromised authorized workload.
5. Identity-provider or federation failure.
6. Audit/provenance gaps.

## Security properties
- No static cloud key is required for the federated path.
- Trust is constrained by issuer, audience, repository, and branch.
- Temporary credentials have bounded lifetime.
- Unauthorized claims are denied.
- Failure does not fall back to static credentials.
- Cloud access can be correlated to the workflow run.

## Limitation
Short-lived credentials reduce the validity window of a stolen credential. They do not prevent compromise of an authorized workload or abuse while valid.