$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
$date = $(get-date -format yyyy-MM-ddTHH-mm)

$vmObject = [System.Collections.ArrayList]::new()

foreach ($sub in $subs)
{
    set-azcontext -Subscription $sub.Name
    Select-AzSubscription -Subscription "$sub"

    $vms=get-azvm
   
    foreach ($vm in $vms)
    {
        $vmsize = $vm.HardwareProfile.VmSize
        $vcores = Get-AzVMSize -VMName $vm.Name -ResourceGroupName $vm.ResourceGroupName | where{$_.Name -eq $vmsize}

        [void]$vmObject.add([PSCustomObject]@{
        Subscription = $sub.name
        Name = $vm.Name
        Resource_Group = $vm.ResourceGroupName
        Location = $vm.Location
        Size = $vm.HardwareProfile.VmSize
        OsType = $vm.StorageProfile.OsDisk.OsType
        Sku = $vm.StorageProfile.ImageReference.Sku
        vCores = $vcores.NumberOfCores
        })
    } 
}
$report = 'VMS_'+'_Report_'+"$date"+'.csv'
$vmObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report