# Evidence Plan

| Claim | Evidence | Status |
|---|---|---|
| No long-lived AWS key required | GitHub OIDC workflow + environment check | To execute |
| Claim-scoped trust | Authorized/unauthorized branch tests | To execute |
| Bounded credential lifetime | STS session configuration + CloudTrail | To execute |
| Exposure-window reduction | Deterministic TTL model | Reproducible |
| Token-exchange latency | Real CI measurements, p50/p95/p99 | To measure |
| Failure-closed | Remove/deny federation and verify no fallback | To execute |

Do not call an experimental result "measured" until it is captured in results/ with environment metadata.