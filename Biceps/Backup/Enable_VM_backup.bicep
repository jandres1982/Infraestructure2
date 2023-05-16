@description('Specifies the location for all resources.')
//param location string = resourceGroup().location
param vaultName string
param vmName string
param backupFabric string = 'Azure'

@allowed([
  'long'
  'medium'
  'short'
])
param backupPolicyName string

var policy = {
  'long': {
    retention: {
      name: 'vm-long-01am-01'
      rg:'rg-nonprod-rmp-backup'
    }
  }
  'medium': {
    retention: {
      name: 'vm-medium-01am-01'
      rg:'rg-nonprod-rmp-backup'
    }
  }
  'short': {
    retention: {
      name: 'vm-short-01am-01'
      rg:'rg-nonprod-rmp-backup'
    }
  }
}



var protectionContainer = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup()};${vmName}'
var protectedItem = 'vm;iaasvmcontainerv2;${resourceGroup()};${vmName}'

resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-06-01' existing = {
  name:vmName
  scope:resourceGroup()

}

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2020-02-02' existing = {
  name: vaultName
  scope:resourceGroup(policy[backupPolicyName].retention.rg)
}

resource vaultName_backupFabric_protectionContainer_protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2020-02-02' = {
  name: '${vaultName}/${backupFabric}/${protectionContainer}/${protectedItem}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: '${recoveryServicesVault.id}/backupPolicies/${policy[backupPolicyName].retention.name}'
    sourceResourceId: virtualMachine.id
  }
}
