#######################################################################
# This script is to deploy a BeyondTrust appliance to Microsoft Azure
# Requires Az version 3.0.0 or above
#######################################################################

# Inherit Powershell defaults, and make ErrorAction = Stop for all CMDlets in this script
$PSDefaultParameterValues = $PSDefaultParameterValues.clone()
$PSDefaultParameterValues += @{'*:ErrorAction' = 'Stop'}
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"


#######################################################################
# Instructions
#
# This script deploys a BeyondTrust Appliance to the Microsoft Azure
#
# STEP 1 (REQUIRED): Fill out these variables
#           resourceGroupName: 
#                  The name of the Resource Group to create the VM in
#           storageAccountName: The name of the Storage Account to 
#                  upload and create VHDs in
#                  NOTES: This must already exist with a container
#                    named the same as `$vhdFolder` (default: vhds)                    
#           vnetName: The name of the virtual network to add the NIC to
#           subnetName: The name of the subnet to add the NIC to
#           location: the Location that the vm should be created in
#                     (must match the location of previous settings)
#           vmName: what name to set the vm to in Azure
#                   (Name must only contain alphanumeric (A-z 0-9)
#                    dash (-), underscore (_), or period (.) )
#######################################################################

$resourceGroupName = ""
$storageAccountName = ""
$vnetName = ""
$subnetName = ""
$location = ""
$vmName = "BeyondTrust-br.v.2"

#######################################################################
# REQUIRED
# Sizes:
#   small: 1-20 licenses
#   medium: 21-100 licenses
#   large: 100+ licenses
#######################################################################

$size = "small"

#######################################################################
# REQUIRED
# Subscription and Tenant are required for Az module
#######################################################################

$subscription = ""
$tenant = ""

#######################################################################
# STEP 2 (OPTIONAL): Change these variables as needed
#         vhdFolder: the blob storage container in the storageAccount
#                    where VHDs will be created (default: vhds)
#         createPublicIP: Whether to create this vm with or without a
#                         public IP [$true or $false] (default: $true)
#         networkSecurityGroup: the nsg to use or create
#                               (if it does not exist, will create one
#                                with ports 80 and 443 open)
#                                (default: BeyondTrust-NSG)
#######################################################################

$vhdFolder = "vhds"
$createPublicIP = $true
$networkSecurityGroup = "BeyondTrust-NSG"

# Azure US Government Account
# Set this to $true if your account is in Azure US Government
$azureUSGovernment = $false

#######################################################################
# STEP 4: Save this file and run
#######################################################################


#######################################################################
# DO NOT EDIT BELOW THIS LINE
#######################################################################

# check required variables are not empty
if(($resourceGroupName -eq '') -or
    ($storageAccountName -eq '') -or
    ($vnetName -eq '') -or
    ($subnetName -eq '') -or
    ($location -eq '') -or
    ($vmName -eq '') -or
    ($vhdFolder -eq '') -or
    ($networkSecurityGroup -eq '')) {
    Write-Host -ForegroundColor Red "Required variable(s) are blank."
    return
}

if ($size -eq "large") {
    $vmSize = "Standard_F8s_v2"
    $dataDisk1size = "100"
    $dataDisk2size = "1000"
} elseif ($size -eq "medium") {
    $vmSize = "Standard_F4s_v2"
    $dataDisk1size = "500"
} else {
    $vmSize = "Standard_DS2_v2"
    $dataDisk1size = "100"
}

# Check for Az PowerShell module
if (-Not (Get-Module -ListAvailable -Name "Az.*")) {
    Write-Host -ForegroundColor RED "Az Modules not found. Please install Az Modules for Powershell. Exiting.."
    return
}

# Setup Connect Arguments
$connect_cmd  = "Connect-AzAccount"
if ($tenant) {
    $connect_cmd += " -TenantId '$($tenant)'"
}
if ($subscription) {
    $connect_cmd += " -Subscription '$($subscription)'"
}
if ($azureUSGovernment) {
    $connect_cmd += " -Environment AzureUSGovernment"
}

# Convert vhdx to vhd for Azure
Convert-VHD -Path BeyondTrust-br.v.2.vhdx -DestinationPath BeyondTrust-br.v.2.vhd

# Connect to Az Account
Invoke-Expression $connect_cmd
# Initialize some variables for this script
$localDiskName = "BeyondTrust-br.v.2.vhd"
$remoteDiskName = "$($vmName).vhd"
if ($azureUSGovernment) {
    $resourceURL = "usgovcloudapi.net"
} else {
    $resourceURL = "windows.net"
}
$remoteVHD = "https://$($storageAccountName).blob.core.$($resourceURL)/$($vhdFolder)/$($remoteDiskName)"
$nicName = "$($vmName)_nic"
$publicIpName = "$($vmName)_ip"

# Check to see if vhd has already been uploaded
Write-Host "Checking for '$remotediskName' in $storageAccountName\$vhdFolder"
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0]
$storageAccountContext = New-AzStorageContext $storageAccountName -StorageAccountKey $storageAccountKey.Value
$storageContainer = Get-AzStorageContainer $vhdFolder -Context $storageAccountContext
if ($storageContainer) {
    $blobs = Get-AzStorageBlob -Container $vhdFolder -Context $storageAccountContext | Where-Object {$_.Name -eq $remoteDiskName}
    if (!$blobs) {
        # The vhd wasn't found.. Upload to Azure!
        Write-Host "$remoteDiskName not found. Uploading to $storageAccountName\vhds"
        Add-AzVhd $resourceGroupName -Destination $remoteVHD -LocalFilePath $localDiskName -ErrorAction Stop
    } else {
        Write-Host "$remoteDiskName found. Skipping Upload."
    }
} else {
    Write-Host -ForegroundColor RED "BLOB storage $storageAccountName\$vhdFolder was not found."
    return
}


# Create a Network Security Group (NSG) if necessary.
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Name $networkSecurityGroup -ErrorAction SilentlyContinue
if (!$nsg) {
    Write-Host "$networkSecurityGroup not found. Creating new Network Security Group"
    $rule1 = New-AzNetworkSecurityRuleConfig -Name "Allow-80" -Description "Allow Port 80" `
    -Access Allow -Protocol * -Direction Inbound -Priority 100 `
    -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 80

    $rule2 = New-AzNetworkSecurityRuleConfig -Name "Allow-443" -Description "Allow Port 443" `
    -Access Allow -Protocol * -Direction Inbound -Priority 101 `
    -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 443
  
    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name $networkSecurityGroup -SecurityRules $rule1,$rule2
    Write-Host "New security group $networkSecurityGroup created"
} else {
    Write-Host "$networkSecurityGroup found"
}

# Set up networking resources
Write-Host "Fetching VNet and Subnet information"
$vnet = Get-AzVirtualNetwork  -ResourceGroupName $resourceGroupName -Name $vnetname
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet

#Write-Host "Checking Network requirements"
if ($createPublicIP) {
    $pip = Get-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
    if (!$pip) {
       Write-Host "Creating a new Dynamic Public IP"
       $pip = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName -Location $location  -AllocationMethod Dynamic
    }
}

$nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if (!$nic) {
    Write-Host "Creating a new NIC"
    if ($createPublicIP) {
        $nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -Subnet $subnet -PublicIpAddress $pip -NetworkSecurityGroup $nsg
    } else {
        $nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -Subnet $subnet -NetworkSecurityGroup $nsg
    }
}

# Configure Virtual Machine parameters
$vm = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id

# Get Storage Account
$storageAccount = Get-AzStorageAccount -Name $storageAccountName -ResourceGroup $resourceGroupName

# Attach OS disk
Write-Host "Attaching OS disk $($vmName)_os_disk"
$osdiskconfig = New-AzDiskConfig -HyperVGeneration "V2" -SkuName StandardSSD_LRS -Location $location -CreateOption Import -sourceUri $remoteVHD -StorageAccountId $storageAccount.id
$osdisk = New-AzDisk -DiskName "$($vmName)_os_disk" -Disk $osdiskconfig -ResourceGroupName $resourceGroupName
$vm = Set-AzVMOSDisk -VM $vm -Name "$($vmName)_os_disk" -ManagedDiskId $osdisk.id -CreateOption Attach -Linux

# Add data disks if necessary
if (Test-Path variable:local:dataDisk1size) {
  Write-Host "Attaching $($vmName)_data_disk1"
  $disk1config = New-AzDiskConfig -SkuName StandardSSD_LRS -Location $location -CreateOption Empty -DiskSizeGB $dataDisk1size
  $disk1 = New-AzDisk -DiskName "$($vmName)_data_disk1" -Disk $disk1config -ResourceGroupName $resourceGroupName
  $vm = Add-AzVMDataDisk -VM $vm -Name "$($vmName)_data_disk1" -CreateOption Attach -ManagedDiskId $disk1.id -Lun 1
}

if (Test-Path variable:local:dataDisk2size) {
  Write-Host "Attaching $($vmName)_data_disk2"
  $disk2config = New-AzDiskConfig -SkuName StandardSSD_LRS -Location $location -CreateOption Empty -DiskSizeGB $dataDisk2size
  $disk2 = New-AzDisk -DiskName "$($vmName)_data_disk2" -Disk $disk2config -ResourceGroupName $resourceGroupName
  $vm = Add-AzVMDataDisk -VM $vm -Name "$($vmName)_data_disk2" -CreateOption Attach -ManagedDiskId $disk2.id -Lun 2
}

# Create the new VM
Write-Host "Creating the BeyondTrust Virtual Machine"
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm

# Wait for an IPAddress to be assigned
if ($createPublicIP) {
    for ($iter = 0; $iter -le 6; $i++) {
        $pip = Get-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroupName
        if ($pip.IpAddress -like "Not Assigned") {
            Start-Sleep -s 5
        } else {
            break
        }
    }

    if ($pip.IpAddress -like "Not Assigned") {
	    Write-Host "$vmName was not assigned a Public IP Address in time. Please find the IP address at https://portal.azure.com/, and for appliance administration navigate to appliance"
    } else {
	    Write-Host "You can access this appliance at https://$($pip.IpAddress)/appliance"
    }
} else {
    Write-Host "For Appliance administration, go to your portal"
}
