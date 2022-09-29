variable "azure_subscription_id" {
  description = "Sub"
  default     = "8528129a-0394-4057-ac4e-0fec3da2246d"
}
variable "network-rg" {
  description = "Resource Group"
  default     = "rg-cis-nonprod-network-01"
}

variable "pe-rg" {
  description = "Resource Group"
  default     = "rg-cis-nonprod-backup-01"
}

variable "network" {
  description = "VNET Name"
  default     = "vnet-nonprod-use2-01"
}

variable "subnet" {
  description = "Subnet Name"
  default     = "sub-generic-privateendpoints-01"
}
variable "pe" {
  description = "Private Endpoint Name"
  default     = "pe-test-terraform-01"
}
