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
