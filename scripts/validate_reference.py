#!/usr/bin/env python3
"""Deterministic validation of the secretless AWS reference implementation."""

from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "infra/aws/main.tf"
WORKFLOW = ROOT / ".github/workflows/aws-oidc-demo.yml"
TRUST = ROOT / "infra/aws/trust-policy.template.json"


def require(text: str, pattern: str, label: str) -> None:
    if not re.search(pattern, text, re.MULTILINE):
        raise AssertionError(f"missing: {label}")


def main() -> None:
    main_tf = MAIN.read_text()
    workflow = WORKFLOW.read_text()
    trust = json.loads(TRUST.read_text())

    require(main_tf, r'url\s*=\s*"https://token\.actions\.githubusercontent\.com"', "GitHub OIDC issuer")
    require(main_tf, r'Action\s*=\s*"sts:AssumeRoleWithWebIdentity"', "web identity federation")
    require(main_tf, r'"token\.actions\.githubusercontent\.com:aud"\s*=\s*"sts\.amazonaws\.com"', "audience restriction")
    require(main_tf, r'"token\.actions\.githubusercontent\.com:sub"\s*=\s*local\.github_subject', "subject restriction")
    require(main_tf, r'max_session_duration\s*=\s*900', "15-minute maximum role session")
    require(main_tf, r'Action\s*=\s*\["s3:GetObject",\s*"s3:ListBucket"\]', "least-privilege S3 actions")
    require(workflow, r'permissions:\n\s+id-token:\s+write', "OIDC token permission")
    require(workflow, r'role-duration-seconds:\s*900', "15-minute workflow session")
    require(workflow, r'test -z "\$\{AWS_ACCESS_KEY_ID\+x\}"', "static-key guard")
    require(workflow, r'aws sts get-caller-identity', "identity proof")
    require(workflow, r'aws s3 ls "s3://\$\{DEMO_BUCKET\}"', "scoped S3 access proof")

    statement = trust["Statement"][0]
    conditions = statement["Condition"]["StringEquals"]
    assert conditions["token.actions.githubusercontent.com:aud"] == "sts.amazonaws.com"
    assert conditions["token.actions.githubusercontent.com:sub"] == "repo:<OWNER>/<REPO>:environment:<ENVIRONMENT>"

    print("PASS: issuer restricted to GitHub Actions OIDC")
    print("PASS: audience restricted to sts.amazonaws.com")
    print("PASS: subject restricted to repository + environment")
    print("PASS: maximum session duration is 15 minutes")
    print("PASS: workflow rejects static AWS access keys")
    print("PASS: workflow proves STS identity and private S3 access")
    print("PASS: trust-policy template matches the implemented environment-scoped model")


if __name__ == "__main__":
    main()
