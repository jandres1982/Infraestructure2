#param([string]$vmName)
#$subs = @("s-sis-eu-nonprod-01","s-sis-ap-prod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01")
#param([string]$vm)
#$vm = "shhwsr2242"
$Servers = Get-Content -Path "Server_List_Covert_to_Standard.txt"

foreach ($vmName in $Servers)
{
    

$subs = @("s-sis-eu-nonprod-01","s-sis-ap-prod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01")

foreach ($sub in $subs)
{
    Select-AzSubscription -Subscription $sub

# Choose between Standard_LRS, StandardSSD_LRS and Premium_LRS based on your scenario
$storageType = 'StandardSSD_LRS'

if (get-azvm -Name $vmName)
    {
    Write-Host "Working in $vmName"
    $vm = get-azvm -Name $vmName
    $rg = $vm.ResourceGroupName
    Stop-AzVM -ResourceGroupName $rg -Name $vm.name -Force
    $osdisk = $vm.StorageProfile.OSDisk.Name
    $disk_info = get-azdisk -ResourceGroupName $rg -DiskName $osdisk
    $disk_info.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
    $disk_info | Update-AzDisk

    $datadisk = $vm.StorageProfile.DataDisks.Name
        foreach ($disk in $datadisk)
                        {
                        $disk_info = get-azdisk -ResourceGroupName $rg -DiskName $disk
                        $disk_info.sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
                        $disk_info | Update-AzDisk

                        }

    Start-AzVM -ResourceGroupName $rg -Name $vm.name
    
    }else
    {
    Write-host "$vmName is not found in $sub"
    }
}


}