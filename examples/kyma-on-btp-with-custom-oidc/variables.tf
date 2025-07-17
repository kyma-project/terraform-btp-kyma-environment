# we're using uppercase variable names, since in some cases (e.g Azure DevOps) the system variables are forced to be uppercase
# TF allows providing variable values as env variables of name name, case sensitive
###
# SAP BTP provider configuration
###
variable "BTP_GLOBAL_ACCOUNT" {
  type        = string
  description = "Subdomain of the SAP BTP global account"
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

variable "BTP_BACKEND_URL" {
  type        = string
  description = "BTP backend URL"
  default     = "https://cli.btp.cloud.sap"
}

variable "BTP_CUSTOM_IAS_TENANT" {
  type        = string
  description = "Custom IAS tenant"
  default     = "custom-tenant"
}

###
# Kyma module
###
variable "BTP_USE_SUBACCOUNT_ID" {
  type        = string
  description = "ID of the subaccount"
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

variable "BTP_KYMA_CUSTOM_ADMINISTRATORS" {
  type    = list(string)
  default = []
}

variable "BTP_CUSTOM_IAS_DOMAIN" {
  type        = string
  description = "Custom IAS domain"
  default     = "accounts.ondemand.com"
}
