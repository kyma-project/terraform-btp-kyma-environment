#!/bin/bash
# Print the BTP subaccount ID recorded in Terraform state, or nothing if state has none.
# Reads the output of `terraform show -json` on stdin.
#
# This deliberately reads the resource out of state rather than using
# `terraform output -raw subaccount_id`: Terraform only writes root outputs after a
# fully successful apply, but the subaccount resource lands in state as soon as it is
# created. Cleanup needs the ID precisely in the case where a later resource failed.

set -e -o pipefail

if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install jq and try again." >&2
  exit 1
fi

# Recursive descent so the resource is found at any module nesting depth.
jq -r '
  [ .. | objects
    | select(.type? == "btp_subaccount" and .name? == "subaccount")
    | .values?.id? // empty
  ] | first // empty
'
