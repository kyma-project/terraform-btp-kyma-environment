#!/bin/bash
# Force delete a BTP subaccount, or do nothing when no subaccount ID was supplied.
# Expects the `btp` CLI on PATH and its configuration in the environment.
#
# An empty ID is a normal outcome, not an error: provisioning can fail before any
# subaccount exists. Passing it through to `btp delete accounts/subaccount ""` makes
# the CLI reject the call and masks the real provisioning failure in the caller's log.

set -e -o pipefail

if [ -z "${BTP_SUBACCOUNT_ID:-}" ]; then
  echo "::notice::No subaccount ID supplied, nothing to delete."
  exit 0
fi

btp login \
  --url "$BTP_BACKEND_URL" \
  --user "$BTP_USER" \
  --password "$BTP_PASSWORD" \
  --idp "$BTP_IDP_TENANT" \
  --subdomain "$BTP_GLOBAL_ACCOUNT"

echo "Deleting $BTP_GLOBAL_ACCOUNT/$BTP_SUBACCOUNT_ID."
btp delete accounts/subaccount "$BTP_SUBACCOUNT_ID" \
  --global-account "$BTP_GLOBAL_ACCOUNT" \
  --force-delete true \
  --confirm true
echo "Deletion request for subaccount $BTP_SUBACCOUNT_ID sent."
