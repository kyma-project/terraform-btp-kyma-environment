terraform {
  # Due to cross variable validation, we must set the required version to 1.9 or higher
  required_version = ">= 1.9.0"
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.18.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.5.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "~> 2.2.0"
    }
  }
}
