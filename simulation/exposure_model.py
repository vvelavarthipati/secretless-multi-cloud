#!/usr/bin/env python3
"""Deterministic credential-validity-window model."""

def reduction(static_ttl: float, federated_ttl: float) -> float:
    return 1.0 - federated_ttl / static_ttl

def main() -> None:
    annual = 365 * 24 * 60
    for ttl in (15, 10):
        pct = reduction(annual, ttl) * 100
        print(f"{ttl:>3} minute token: {pct:.6f}% shorter validity window")
    print("\nThis is a validity-window metric, not a breach-probability estimate.")

if __name__ == "__main__":
    main()
