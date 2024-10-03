terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "1.7.0"
    }
    jq = {
      source  = "massdriver-cloud/jq"
    }
    http = {
      source = "hashicorp/http"
      version = "3.4.5"
    }
  }
}


provider "jq" {}
provider "http" {}

provider "btp" {
  globalaccount = var.BTP_GLOBAL_ACCOUNT
  cli_server_url = var.BTP_BACKEND_URL
  idp            = var.BTP_CUSTOM_IAS_TENANT
  username = var.BTP_BOT_USER
  password = var.BTP_BOT_PASSWORD
}

module "kyma" {
  source = "../.."
  BTP_KYMA_PLAN = var.BTP_KYMA_PLAN
  BTP_NEW_SUBACCOUNT_NAME = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_CUSTOM_IAS_TENANT = var.BTP_CUSTOM_IAS_TENANT
  BTP_CUSTOM_IAS_DOMAIN = var.BTP_CUSTOM_IAS_DOMAIN
  BTP_KYMA_REGION = var.BTP_KYMA_REGION
  BTP_BOT_USER = var.BTP_BOT_USER
  BTP_BOT_PASSWORD = var.BTP_BOT_PASSWORD
  BTP_NEW_SUBACCOUNT_REGION = var.BTP_NEW_SUBACCOUNT_REGION
  BTP_KYMA_MODULES = var.BTP_KYMA_MODULES
}

output "subaccount_id" {
  value = module.kyma.subaccount_id
}

output "service_instance_id" {
  value = module.kyma.service_instance_id
}

output "cluster_id" {
  value = module.kyma.cluster_id
}

output "domain" {
  value = module.kyma.domain
}
