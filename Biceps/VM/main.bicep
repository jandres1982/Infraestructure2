@description('Size of VM')
param vmSize string = 'Standard_D2ds_v5'

@description('Existing VNET')
param existingVnetName string = 'EU-NONPROD-VNET'

@description('Existing Subnet')
param existingSubnetName string = 'Test'

@description('The name of the administrator of the new VM.')
param adminUsername string = 'ldmsosd'

@description('The password for the administrator account of the new VM.')
@secure()
param adminPassword string = 'Newsetup1234'

@description('Image Id')
param imageid string = '/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-imagegallery-01/providers/Microsoft.Compute/galleries/ig_gis_win_prod/images/img-prod-2019datacenter-19052021-01/versions/0.0.1'

@description('The name of the storage account.')
param storageAccountName string = 'stnonproddiagnostic0001'

@allowed(['1'
'2'
'3'])
param zone string = '1'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('VM name')
param vmname string = 'zzzwsr0005'

var nicName = '${vmname}-nic'

resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: existingVnetName
  scope: resourceGroup('rg-cis-nonprod-network-01')
}

resource existingSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: existingVirtualNetwork
  name: existingSubnetName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
  scope: resourceGroup('rg-cis-nonprod-storage-01')
}

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
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
  zones: [
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
        id: imageid
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
          diskSizeGB: 5
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
