#!/bin/bash
# Covers the CI regression where a failed `terraform apply` left a subaccount behind
# with no way to identify it, so cleanup could not delete it and the leaked subaccount
# consumed global account quota on every later run.

set -e -o pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
EXTRACT="$REPO_ROOT/.github/actions/create-sap-btp-kyma/extract_subaccount_id.sh"

failures=0

expect_equal() {
  local description="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  ok: $description"
  else
    echo "  FAIL: $description: expected '$expected', got '$actual'" >&2
    failures=$((failures + 1))
  fi
}

echo "extract_subaccount_id.sh"

# The case that broke CI: apply failed on a later resource, so Terraform never wrote
# root outputs, but the subaccount itself is already in state and must be cleaned up.
expect_equal "finds the subaccount in a partially applied state" \
  "11111111-2222-3333-4444-555555555555" \
  "$("$EXTRACT" < "$TEST_DIR/fixtures/state_partial_apply.json")"

expect_equal "returns nothing when state holds no subaccount" \
  "" \
  "$("$EXTRACT" < "$TEST_DIR/fixtures/state_empty.json")"

exit "$failures"
