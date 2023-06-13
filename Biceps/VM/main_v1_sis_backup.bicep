@allowed([
  's-sis-eu-nonprod-01'
  's-sis-eu-prod-01'
  's-sis-ap-prod-01'
  's-sis-am-nonprod-01'
  's-sis-am-prod-01'
  's-sis-ch-nonprod-01'
  's-sis-ch-prod-01'
])
param sub string

var subenvmap = {
  's-sis-eu-nonprod-01': {
    vnet:{
      name: 'EU-NONPROD-VNET'
      scope:'rg-cis-nonprod-network-01'
    }
    storage: {
      name: 'stnonproddiagnostic0001'
      scope:'rg-cis-nonprod-storage-01'
    }
    backup: {
      name:'rsv-nonprod-euno-zrsbackup-01'
      scope:'rg-cis-nonprod-backup-01'
    }
  }
  's-sis-eu-prod-01': {
    vnet: {
      name:'EU-PROD-VNET'
      scope:'RG_NETWORK_PROD'
    }
    storage: {
    name:'stproddiagnostic0002'
    scope:'rg-cis-prod-storage-01'
    }
    backup: {
      name:'rsv-prod-euno-zrsbackup-01'
      scope:'rg-cis-prod-backup-01'
    }
}
's-sis-ap-prod-01': {
  vnet: {
    name:'vnet-prod-asse-01'
    scope:'rg-cis-prod-network-02'
  }
  storage: {
  name:'stproddiagnostic0003'
  scope:'rg-cis-prod-storage-02'
  }
  backup: {
    name:'rsv-prod-asse-zrsbackup-01'
    scope:'rg-cis-prod-backup-01'
  }
}
's-sis-am-nonprod-01': {
  vnet: {
    name:'vnet-nonprod-use2-01'
    scope:'rg-cis-nonprod-network-01'
  }
  storage: {
  name:'stnonproddiagnostic0002'
  scope:'rg-cis-nonprod-storage-01'
  }
  backup: {
    name:'rsv-nonprod-use2-zrsbackup-01'
    scope:'rg-cis-nonprod-backup-01'
  }
}
's-sis-am-prod-01': {
  vnet: {
    name:'vnet-prod-use2-01'
    scope:'rg-cis-prod-network-01'
  }
  storage: {
  name:'stproddiagnostic0004'
  scope:'rg-cis-prod-storage-01'
  }
  backup: {
    name:'rsv-prod-use2-zrsbackup-01'
    scope:'rg-cis-prod-backup-01'
  }
}
's-sis-ch-nonprod-01': {
  vnet: {
    name:'vnet-nonprod-sn-01'
    scope:'rg-cis-prod-network-01'
  }
  storage: {
  name:'stnonproddiagnostic0003'
  scope:'rg-cis-nonprod-storage-01'
  }
  backup: {
    name:'rsv-nonprod-chno-zrsbackup-01'
    scope: 'rg-cis-nonprod-backup-01'
  }
}
's-sis-ch-prod-01': {
  vnet: {
    name:'vnet-prod-sn-01'
    scope:'rg-cis-prod-network-01'
  }
  storage: {
  name:'stproddiagnostic0001'
  scope:'rg-cis-prod-storage-01'
  }
  backup: {
    name:'rsv-prod-chno-zrsbackup-01'
    scope:'rg-cis-prod-backup-01'
  }
}
}


@description('Backup Parameters')
param backupFabric string = 'Azure'

var protectionContainer = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup(subenvmap[sub].backup.scope)};${vmname}'
var protectedItem = 'vm;iaasvmcontainerv2;${resourceGroup().name};${vmname}'

@allowed([
  'vm-short-01am-01'
  'vm-medium-01am-01'
  'vm-long-01am-01'
])
param policy string

@description('Size of VM')
param vmSize string

@description('Data Size')
param datasize int

//@description('Existing VNET')
//param vnet string = 'EU-NONPROD-VNET'

@description('Existing Subnet')
param existingSubnetName string

@description('The name of the administrator of the new VM.')
param adminUsername string = 'ldmsosd'

@description('The password for the administrator account of the new VM.')
@secure()
param adminPassword string = 'Newsetup1234'

//@description('The name of the storage account.')
//param storageAccountName string = 'stnonproddiagnostic0001'

@allowed([
  '1'
  '2'
  '3'
])
param zone string

param ipset bool

@allowed([
  '2016'
  '2019'
  '2022'
])
param osversion string

var os2022 = '/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-imagegallery-01/providers/Microsoft.Compute/galleries/ig_gis_win_prod/images/img-prod-2022datacenter-16032023-01/versions/0.0.1'
var os20162019 = '/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-imagegallery-01/providers/Microsoft.Compute/galleries/ig_gis_win_prod/images/img-prod-${osversion}datacenter-19052021-01/versions/0.0.1'

//@description('Image Id')
//var imageid = '/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-imagegallery-01/providers/Microsoft.Compute/galleries/ig_gis_win_prod/images/img-prod-${osversion}datacenter-19052021-01/versions/0.0.1'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Ip address')
param ip string

@description('VM name')
param vmname string

var nicName = '${vmname}-nic'

resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: subenvmap[sub].vnet.name
  scope: resourceGroup(subenvmap[sub].vnet.scope)
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: existingVirtualNetwork
  name: existingSubnetName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: subenvmap[sub].storage.name
  scope: resourceGroup(subenvmap[sub].storage.scope)
}


resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: (ipset ? 'Static' : 'Dynamic')
          privateIPAddress: (ipset ? ip :'')
          subnet: {
            id: existingSubnet.id
          }
        }
      }
    ]
  }
}


resource virtualMachine 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmname
  location: location
  zones:[
    zone
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmname
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        id: ((osversion == '2022') ? os2022 : os20162019)
    }
      osDisk: {
        name: '${vmname}-OsDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        osType: 'Windows'
        managedDisk:{
          storageAccountType:'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          name: '${vmname}-DataDisk'
          caching: 'None'
          createOption: 'Empty'
          diskSizeGB: datasize
          lun: 0
          managedDisk:{
            storageAccountType:'StandardSSD_LRS'
          }
        }
      ]
    }
    networkProfile: { 
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageAccount.properties.primaryEndpoints.blob
      }
    }
  }
}


resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2020-02-02' existing = {
    name: subenvmap[sub].backup.name
    scope: resourceGroup(subenvmap[sub].backup.scope)
  }

  output rsv string = recoveryServicesVault.id
  output rsvname string = recoveryServicesVault.name
  

  resource vaultName_backupFabric_protectionContainer_protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2020-02-02' = {
    name: '${subenvmap[sub].backup.name}/${backupFabric}/${protectionContainer}/${protectedItem}'
    properties: {
      protectedItemType: 'Microsoft.Compute/virtualMachines'
      policyId: '${recoveryServicesVault.id}/backupPolicies/${policy}'
      sourceResourceId: virtualMachine.id
    }
  }
