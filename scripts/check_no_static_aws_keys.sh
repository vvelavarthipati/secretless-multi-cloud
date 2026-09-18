#!/usr/bin/env bash
set -euo pipefail

if env | grep -Eq '^AWS_(ACCESS_KEY_ID|SECRET_ACCESS_KEY|SESSION_TOKEN)='; then
  echo 'Static AWS environment credentials detected; failing closed.' >&2
  exit 1
fi

echo 'No AWS environment credentials detected.'