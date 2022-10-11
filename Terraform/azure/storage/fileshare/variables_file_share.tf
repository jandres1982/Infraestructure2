variable "azure_subscription_id" {
  description = "Sub"
  default     = "505ead1a-5a5f-4363-9b72-83eb2234a43d"
}
variable "rg" {
  description = "Resource Group"
  default     = "rg-shh-prod-rmp-01"
}
variable "storageaccountname" {
  description = "Storage Account"
  default     = "stprodsqlfileshare02"
}
variable "sharename" {
  description = "File Share Name"
  default     = "shhwsr2526fullweekly"
}