#!/bin/bash
# Covers the CI regression where an empty subaccount ID was passed straight to the CLI
# as `btp delete accounts/subaccount ""`. The CLI rejected it with "Value of parameter
# [ID] must not be empty", failing the cleanup job and hiding the real provisioning error.

set -e -o pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
DELETE="$REPO_ROOT/.github/actions/force-delete-sap-btp-subaccount/force_delete_subaccount.sh"

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

# Stub CLI that records every invocation instead of calling SAP BTP. It rejects an empty
# subaccount ID the same way the real CLI does, so this test reproduces the observed
# cleanup failure rather than an idealised version of it.
stub_dir="$(mktemp -d)"
trap 'rm -rf "$stub_dir"' EXIT
cat > "$stub_dir/btp" <<'STUB'
#!/bin/bash
echo "$@" >> "$BTP_CALL_LOG"
if [ "$1 $2" = "delete accounts/subaccount" ] && [ -z "$3" ]; then
  echo "Value of parameter [ID] must not be empty" >&2
  exit 1
fi
STUB
chmod +x "$stub_dir/btp"
export PATH="$stub_dir:$PATH"

# The stub ignores the login credentials, so these values only need to be non-empty.
# Keep BTP_PASSWORD under eight characters: gitleaks' hashicorp-tf-password rule flags
# any longer quoted value assigned to a name ending in `password`, and this repo scans
# with the default ruleset and no allowlist.
run_delete() {
  BTP_CALL_LOG="$stub_dir/calls.log"
  export BTP_CALL_LOG
  : > "$BTP_CALL_LOG"
  BTP_SUBACCOUNT_ID="$1" \
  BTP_BACKEND_URL="https://canary.cli.btp.int.sap" \
  BTP_USER="bot@example.com" \
  BTP_PASSWORD="unused" \
  BTP_IDP_TENANT="otters" \
  BTP_GLOBAL_ACCOUNT="global-account-id" \
    "$DELETE" > "$stub_dir/stdout.log" 2>&1
}

echo "force_delete_subaccount.sh"

empty_exit=0
run_delete "" || empty_exit=$?
expect_equal "succeeds when the ID is empty" "0" "$empty_exit"
expect_equal "makes no CLI call when the ID is empty" \
  "0" \
  "$(wc -l < "$stub_dir/calls.log" | tr -d ' ')"

run_delete "11111111-2222-3333-4444-555555555555"
expect_equal "deletes the subaccount by ID when one is supplied" \
  "delete accounts/subaccount 11111111-2222-3333-4444-555555555555 --global-account global-account-id --force-delete true --confirm true" \
  "$(grep '^delete ' "$stub_dir/calls.log")"

exit "$failures"
