#!/bin/bash
# Covers the CI regression where a secret-shaped placeholder in a test tripped the
# gitleaks scan job. The pull-gitleaks workflow scans the pull request's whole commit
# range, so such a finding cannot be cleared by a later commit: the branch history has
# to be rewritten. Catching it before the commit is pushed is much cheaper.
#
# This is a local convenience check. CI coverage comes from pull-gitleaks, so the gate
# job does not install the binary and this test skips there.

set -e -o pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"

echo "secret_scan"

if ! command -v gitleaks &> /dev/null; then
  echo "  skip: gitleaks not installed, see .github/workflows/pull-gitleaks.yml"
  exit 0
fi

# --no-git scans files on disk and honours .gitignore, so ignored local credential files
# stay out of the report while anything committable is included.
if output="$(gitleaks detect --no-git --source "$REPO_ROOT" --verbose --redact 2>&1)"; then
  echo "  ok: no secrets detected in the working tree"
else
  echo "  FAIL: gitleaks reported a finding" >&2
  echo "$output" | sed 's/^/    /' >&2
  echo "  Remove the value, or if it is a real local credential file, add it to .gitignore." >&2
  exit 1
fi
