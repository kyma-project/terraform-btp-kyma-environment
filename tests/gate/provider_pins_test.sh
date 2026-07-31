#!/bin/bash
# Covers the recurring CI regression where a consumer of this module pinned a provider
# version of its own. Consumers fetch the module from `main`, so Terraform intersects
# both constraint sets; as soon as the two drift apart the intersection is empty and
# `terraform init` fails with "no available releases match the given constraints",
# which surfaces as "Missing required provider" in the Terraform Validation Check.
#
# Dependabot cannot keep these in step: it is refused write access under .github/, so
# the pins there silently rot. See .github/dependabot.yml.

set -e -o pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/../.." && pwd)"

# Directories holding configs that consume the module from `main`.
CONSUMER_DIRS=(
  "examples"
  ".github/actions"
)

failures=0

echo "provider_pins"

for dir in "${CONSUMER_DIRS[@]}"; do
  while IFS= read -r file; do
    # `version` is only meaningful inside required_providers, which is the only place
    # these configs use the keyword at all.
    if pinned="$(grep -n '^[[:space:]]*version[[:space:]]*=' "$file")"; then
      relative="${file#"$REPO_ROOT"/}"
      echo "  FAIL: $relative pins a provider version:" >&2
      echo "$pinned" | sed 's/^/    /' >&2
      failures=$((failures + 1))
    fi
  done < <(find "$REPO_ROOT/$dir" -name '*.tf' -type f)
done

if [ "$failures" -eq 0 ]; then
  echo "  ok: no module consumer pins a provider version"
else
  echo "  Remove the constraint and let the module's own provider.tf govern." >&2
fi

exit "$failures"
