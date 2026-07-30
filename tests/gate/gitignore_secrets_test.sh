#!/bin/bash
# Covers the near miss where .gitignore listed credential files per directory
# (examples/*/*.tfvars, tests/btp-e2e-test/terraform.tfvars, ...) so a tfvars file in a
# scratch directory outside those paths stayed stageable while holding a real bot
# password. Any directory can hold one, so the rules have to be global.
#
# git check-ignore evaluates patterns and does not need the paths to exist.

set -e -o pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"
cd "$REPO_ROOT"

echo "gitignore_secrets"

# Paths outside the directories the original per-directory rules enumerated.
MUST_IGNORE="tf/terraform.tfvars scratch/terraform.tfvars a/b/c/secrets.tfvars
tf/terraform.tfstate scratch/terraform.tfstate.backup tf/kubeconfig.yaml"

# Tracked templates must stay visible, or contributors lose the documented examples.
MUST_NOT_IGNORE="examples/kyma-on-btp-new-sa/terraform.tfvars.example
examples/kyma-on-btp-reuse-sa/terraform.tfvars.example
examples/kyma-on-btp-with-custom-oidc/terraform.tfvars.example"

failures=0

for path in $MUST_IGNORE; do
  if git check-ignore -q "$path"; then
    echo "  ok: $path is ignored"
  else
    echo "  FAIL: $path is not ignored and could be committed with live credentials" >&2
    failures=$((failures + 1))
  fi
done

for path in $MUST_NOT_IGNORE; do
  if git check-ignore -q "$path"; then
    echo "  FAIL: $path is ignored, but this template is meant to be tracked" >&2
    failures=$((failures + 1))
  else
    echo "  ok: $path stays tracked"
  fi
done

exit "$failures"
