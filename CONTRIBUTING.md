# Contributing

Contributions from cloud architects, platform engineers, security engineers, and researchers are welcome.

## Workflow

1. Search existing issues before opening a new one.
2. Fork the repository and create a focused branch.
3. Describe the threat model and intended behavior for security-related changes.
4. Add or update tests and validation scripts.
5. Run the relevant checks and include their output in your pull request.
6. Update documentation and examples when behavior changes.

## Security requirements

- Never commit access keys, tokens, private keys, real credentials, or customer data.
- Use short-lived workload identity credentials and least-privilege policies in examples.
- Keep account IDs, project IDs, and other environment-specific values as placeholders unless they are intentionally public test values.
- Do not weaken trust policies or validation checks without documenting the threat and mitigation.
- Test in a non-production account before attempting cloud deployment.

## Research integrity

Clearly label simulated, estimated, and measured results. Include configuration and reproduction steps. Preserve negative or inconclusive results and document limitations.

## Pull requests

Explain the problem, design, validation performed, security implications, and operational trade-offs. Focused, reviewable pull requests are preferred.
