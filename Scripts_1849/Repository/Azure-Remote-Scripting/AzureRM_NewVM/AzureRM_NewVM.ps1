# Credentials for Local Admin account you created in the sysprepped (generalized) vhd image
$VMLocalAdminUser = "LDMSOSD"
$VMLocalAdminSecurePassword = ConvertTo-SecureString "Newsetup123456789" -AsPlainText -Force
## Azure Account
$LocationName = "westeurope"
$ResourceGroupName = "SDG-Test"
# This a Premium_LRS storage account.
# It is required in order to run a client VM with efficiency and high performance.
$StorageAccount = "schindlerstoragetest"

## VM

$ComputerName = "ZZZWSR0052"
$OSDiskUri = "https://schindlerstoragetest.blob.core.windows.net/vhdtest/windows2019_VHD_FIX.vhd"
#$SourceImageUri = "https://schindlerstoragetest.blob.core.windows.net/vhdtest/windows2019_VHD_FIX.vhd"
$VMName = "$ComputerName"
$OSDiskName = "$ComputerName`_Disk1"
# Modern hardware environment with fast disk, high IOPs performance.
# Required to run a client VM with efficiency and performance
$VMSize = "Standard_B2s"
$OSDiskCaching = "ReadWrite"
$OSCreateOption = "FromImage"

## Networking
#$DNSNameLabel = "mydnsname" # mydnsname.westus.cloudapp.azure.com
$Virtual_network = Get-AzureRmVirtualNetwork -Name "SDG-TEST-NET" -ResourceGroupName "SDG-TEST"
$NICName = "$ComputerName`_001"
$PublicIPAddressName = "none"
$SubnetName = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $Virtual_network -name "default"
$SubnetAddressPrefix = "10.57.255.0/24"
$VnetAddressPrefix = "10.57.0.0/16"
$Disk_Config = "Premium_LRS"
$Security_Group = Get-AzureRmNetworkSecurityGroup -Name "net1" -ResourceGroupName "sdg-test"
#$SingleSubnet = Set-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName
#$Vnet = Set-AzureRmVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
#$PIP = New-AzureRmPublicIpAddress -Name $PublicIPAddressName -DomainNameLabel $DNSNameLabel -ResourceGroupName $ResourceGroupName -Location $LocationName -AllocationMethod Dynamic

#$Subnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $Virtual_network -name default | Select-Object -Property *
#$NIC = New-AzureRmNetworkInterface -Name $NICName -NetworkSecurityGroup $Security_Group

$IPconfig = New-AzureRmNetworkInterfaceIpConfig -Name "IPConfig1" -PrivateIpAddressVersion IPv4 -SubnetId $SubnetName.ID
$Network_Interface = New-AzureRmNetworkInterface -Name "$NICName" -ResourceGroupName "$ResourceGroupName" -Location "$LocationName" -IpConfiguration $IPconfig
$OSDiskName = "$ComputerName`_Disk_001"
#-PublicIpAddressId $PIP.Id
$diskconfig = New-AzureRmDiskConfig -Location $LocationName -DiskSizeGB "100" -AccountType $Disk_Config -OsType Windows -CreateOption Empty
New-AzureRmDisk -ResourceGroupName $ResourceGroupName -DiskName $OSDiskName -Disk $diskconfig


$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -NetworkInterface $Network_Interface
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -SourceImageUri $SourceImageUri -Caching $OSDiskCaching -CreateOption $OSCreateOption -Windows

New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose