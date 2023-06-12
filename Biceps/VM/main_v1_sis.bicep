@allowed([
  's-sis-eu-nonprod-01'
  's-sis-eu-prod-01'
  's-sis-ap-prod-01'
  's-sis-am-nonprod-01'
  's-sis-am-prod-01'
  's-sis-ch-nonprod-01'
  's-sis-ch-prod-01'
  's-sis-cn-prod-01'
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
}
's-sis-cn-prod-01': {
  vnet: {
    name:'vnet-scn-prod-cn3-01'
    scope:'rg-cis-prod-network-01'
  }
  storage: {
  name:'stproddiagnostic0006'
  scope:'rg-cis-prod-storage-01'
  }
}
}

@description('Size of VM')
param vmSize string = 'Standard_D2ds_v5'

@description('Data Size')
param datasize int

//@description('Existing VNET')
//param vnet string = 'EU-NONPROD-VNET'

@description('Existing Subnet')
param existingSubnetName string = 'sub-Infrastructure-IaaS-Subnet-01'

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
param vmname string = 'zzzwsr0005'

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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: ip
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
