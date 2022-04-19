RecoveryServicesResources
| where type == "microsoft.recoveryservices/vaults/backupfabrics/protectioncontainers/protecteditems"
| where properties.backupManagementType == "AzureIaasVM"
| extend friendlyName = properties.friendlyName
| extend policyName = properties.policyName
| project friendlyName,policyName