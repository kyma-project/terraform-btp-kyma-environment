#!/bin/bash
# Covers the CI regression where a workflow that provisions real BTP resources left
# cleanup on the happy path only. push-e2e-test ran `terraform destroy` as the last
# command of the step that also asserted against the cluster, so any failed assertion
# skipped the destroy and leaked a subaccount, which then consumed global account
# quota until someone deleted it by hand.
#
# Every provisioning workflow must therefore clean up in a step guarded by always().

set -e -o pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"

echo "workflow_cleanup"

if ! python3 -c 'import yaml' 2> /dev/null; then
  echo "  skip: python3 with PyYAML unavailable"
  exit 0
fi

PROVISIONING_WORKFLOWS="push-actions.yml push-e2e-test.yml"

failures=0
for workflow in $PROVISIONING_WORKFLOWS; do
  if python3 - "$REPO_ROOT/.github/workflows/$workflow" <<'PY'
import sys, yaml

path = sys.argv[1]
with open(path) as handle:
    workflow = yaml.safe_load(handle)

CLEANUP_MARKERS = ("force-delete-sap-btp-subaccount", "terraform destroy")

for job in workflow["jobs"].values():
    for step in job["steps"]:
        body = str(step.get("uses", "")) + str(step.get("run", ""))
        if any(marker in body for marker in CLEANUP_MARKERS):
            if "always()" in str(step.get("if", "")):
                sys.exit(0)
sys.exit(1)
PY
  then
    echo "  ok: $workflow cleans up in an always() step"
  else
    echo "  FAIL: $workflow has no cleanup step guarded by always()" >&2
    echo "    A failure before cleanup would leak a BTP subaccount and consume quota." >&2
    failures=$((failures + 1))
  fi
done

exit "$failures"
