terraform {
  # No provider version constraints here on purpose. This config consumes the
  # module pinned to a released tag below, so the module's own provider.tf is the
  # single source of truth. Pinning providers again here would let the two
  # constraint sets drift into an empty intersection, and Dependabot cannot repair
  # such a pin because it is refused write access under .github/ (see
  # .github/dependabot.yml).
  required_providers {
    btp = {
      source = "SAP/btp"
    }
    terracurl = {
      source = "devops-rob/terracurl"
    }
  }
}

provider "btp" {
  globalaccount  = var.BTP_GLOBAL_ACCOUNT
  cli_server_url = var.BTP_BACKEND_URL
  idp            = var.BTP_CUSTOM_IAS_TENANT
  username       = var.BTP_BOT_USER
  password       = var.BTP_BOT_PASSWORD
}

provider "terracurl" {}

module "kyma" {
  # Pin to a released tag rather than the mutable `main` branch: this action runs
  # in the credentialed `secrets` environment (see push-actions.yml), so the module
  # it executes must be a reviewed, immutable artifact. Bump this tag by hand on
  # each release -- Dependabot cannot do it, as it is refused write access under
  # .github/ (see .github/dependabot.yml).
  source = "git::https://github.com/kyma-project/terraform-btp-kyma-environment.git?ref=1.1.0"

  BTP_NEW_SUBACCOUNT_NAME        = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_NEW_SUBACCOUNT_REGION      = var.BTP_NEW_SUBACCOUNT_REGION
  BTP_KYMA_PLAN                  = var.BTP_KYMA_PLAN
  BTP_KYMA_REGION                = var.BTP_KYMA_REGION
  BTP_KYMA_MODULES               = jsondecode(var.BTP_KYMA_MODULES_STRINGIFIED)
  BTP_KYMA_AUTOSCALER_MIN        = var.BTP_KYMA_AUTOSCALER_MIN
  BTP_KYMA_CUSTOM_ADMINISTRATORS = jsondecode(var.BTP_KYMA_CUSTOM_ADMINISTRATORS)
  store_kubeconfig_locally       = true
}

output "subaccount_id" {
  value = module.kyma.subaccount_id
}
