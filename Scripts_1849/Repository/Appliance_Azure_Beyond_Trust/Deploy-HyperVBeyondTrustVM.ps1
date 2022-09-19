########################################################
## BeyondTrust Hyper-V Deployment script
##
##  This script will create a vm using
##  the BeyondTrust VHD.
##  Refer to BeyondTrust support documentation for custom
##  deployment options.
##
## Required variables:
## vmName: What to call this vm in Hyper-V
## vmLocation: the folder to create this vm in
## vmSwitch: the switch to attach this vm to
## BeyondTrustVHD:
##     The name of the vhd provided by BeyondTrust.
##     THIS VHD SHOULD ALREADY BE IN $vmLocation
########################################################

$vmName = ""
$vmLocation = ""
$vmSwitch = ""
$beyondtrustVHD = "BeyondTrust-br.v.2.vhdx"

########################################################
## Select a size based on the number of
##  licenses or endpoints. Only uncomment one.
##  (Refer to BeyondTrust support for details)
##
## Small (1-20 licenses or 1-3000 endpoints) (Default)
$size = "small"

## Medium (20-100 licenses or 3001-15000 endpoints)
#$size = "medium"

## Large (100+ licenses or 15000+ endpoints)
#$size = "large"

########################################################
## BEGIN SCRIPT
##

if ($size -eq 'large') {
    $cpu = 8
    $memory = 16GB
    $disk_1_size = 100GB
    $disk_2_size = 1000GB
} elseif ($size -eq 'medium') {
    $cpu = 4
    $memory = 8GB
    $disk_1_size = 500GB
} else {
    # Anything else defaults to small
    $cpu = 2
    $memory = 4GB
    $disk_1_size = 100GB
}


# create disk 1
$vhd1 = New-VHD -Path "$vmLocation\$vmName-datadisk1.vhdx" -SizeBytes $disk_1_size

if (Test-Path variable:local:disk_2_size) {
    # create disk 2
    $vhd2 = New-VHD -Path "$vmLocation\$vmName-datadisk2.vhdx" -SizeBytes $disk_2_size
}

# create the VM
$vm = New-VM -Name $vmName -MemoryStartupBytes $memory -BootDevice VHD -VHDPath "$vmLocation\$beyondtrustVHD" -Path $vmLocation -Generation 2 -Switch $vmSwitch

# set the processor count
Set-VMProcessor -VM $vm -Count $cpu

# attach the disk(s)
Add-VMHardDiskDrive -VMName $vm.Name -Path $vhd1.Path
if (Test-Path variable:local:vhd2) {
    Add-VMHardDiskDrive -VMName $vm.Name -Path $vhd2.Path
}

# disable secure boot
Set-VMFirmware -EnableSecureBoot Off -VM $vm

# start the vm
Start-VM -VM $vm

