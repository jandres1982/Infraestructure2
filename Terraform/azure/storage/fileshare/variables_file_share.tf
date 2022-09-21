variable "azure_subscription_id" {
  description = "Sub"
  default     = "7fa3c3a2-7d0d-4987-a30c-30623e38756c"
}
variable "rg" {
  description = "Resource Group"
  default     = "rg-shh-test-sqlfileshare-01"
}
variable "location" {
  description = "Location"
  default     = "North Europe"
}
variable "storageaccount" {
  description = "Storage Account"
  default     = "sttestsqlfileshare01"
}
variable "sharename" {
  description = "File Share Name"
  default     = "sql-backup"
}