#!/bin/bash
# Run every gate test. These are deterministic, need no network and no BTP credentials,
# and are expected to finish in well under a second so they can run on every commit.

set -e -o pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

failures=0
for test in "$TEST_DIR"/*_test.sh; do
  if ! "$test"; then
    failures=$((failures + 1))
  fi
done

echo
if [ "$failures" -eq 0 ]; then
  echo "All gate tests passed."
else
  echo "$failures gate test file(s) failed." >&2
fi

exit "$failures"
