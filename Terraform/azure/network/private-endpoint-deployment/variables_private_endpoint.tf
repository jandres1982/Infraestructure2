variable "azure_subscription_id" {
  description = "Sub"
  default     = "7fa3c3a2-7d0d-4987-a30c-30623e38756c"
}
variable "rg" {
  description = "Resource Group"
  default     = "rg-shh-test-sqlfileshare-01"
}

variable "network" {
  description = "VNET Name"
  default     = "test"
}

variable "subnet" {
  description = "Subnet Name"
  default     = "sttestsqlfileshare02"
}
variable "pe" {
  description = "Private Endpoint Name"
  default     = "test"
}
