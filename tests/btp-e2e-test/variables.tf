# we're using uppercase variable names, since in some cases (e.g Azure DevOps) the system variables are forced to be uppercase
# TF allows providing variable values as env variables of name name, case sensitive

###
# SAP BTP provider configuration
###
variable "BTP_GLOBAL_ACCOUNT" {
  type        = string
  description = "Subdomain fo the SAP BTP global account"
}

variable "BTP_BOT_USER" {
  type        = string
  description = "Bot account name"
}

variable "BTP_BOT_PASSWORD" {
  type        = string
  description = "Bot account password"
  sensitive   = true
}

variable "BTP_CUSTOM_IAS_TENANT" {
  type        = string
  description = "Custom IAS tenant"
  default     = "custom-tenant"
}

variable "BTP_BACKEND_URL" {
  type        = string
  description = "BTP backend URL"
  default     = "https://cli.btp.cloud.sap"
}

###
# Kyma module
###
variable "BTP_NEW_SUBACCOUNT_NAME" {
  type        = string
  description = "Subaccount name"
  default     = null
}

variable "BTP_NEW_SUBACCOUNT_REGION" {
  type        = string
  description = "Region name"
  default     = null
}

variable "BTP_KYMA_PLAN" {
  type        = string
  description = "Plan name"
  default     = "azure"
}


variable "BTP_KYMA_REGION" {
  type        = string
  description = "Kyma region"
  default     = "westeurope"
}

