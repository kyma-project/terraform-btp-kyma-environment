terraform {
  # No version constraints here on purpose: this example consumes the module from
  # `main`, so the module's own provider.tf is the single source of truth. Pinning
  # again here would let the two constraint sets drift into an empty intersection.
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
