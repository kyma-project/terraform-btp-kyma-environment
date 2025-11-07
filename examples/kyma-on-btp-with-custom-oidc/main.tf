locals {
  oidc_config = {
    groupsClaim    = "groups"
    signingAlgs    = ["RS256"]
    usernameClaim  = "sub"
    usernamePrefix = "-"
    clientID       = var.BTP_KYMA_CUSTOM_OIDC_CLIENT_ID
    issuerURL      = var.BTP_KYMA_CUSTOM_OIDC_ISSUER_URL
    requiredClaims = []
  }
}



module "kyma" {

  # Replace with version you want to use - avoid using main as version constraint
  source = "git::https://github.com/kyma-project/terraform-btp-kyma-environment.git?ref=main"

  BTP_NEW_SUBACCOUNT_NAME        = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_NEW_SUBACCOUNT_REGION      = var.BTP_NEW_SUBACCOUNT_REGION
  BTP_KYMA_REGION                = var.BTP_KYMA_REGION
  BTP_KYMA_PLAN                  = var.BTP_KYMA_PLAN
  BTP_KYMA_CUSTOM_OIDC           = local.oidc_config
  BTP_KYMA_CUSTOM_ADMINISTRATORS = var.BTP_KYMA_CUSTOM_ADMINISTRATORS
  store_cacert_locally           = true
  store_kubeconfig_locally       = true
}
