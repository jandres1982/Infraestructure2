#$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01","s-sis-ch-prod-01","s-sis-ch-nonprod-01")
$subs =  Get-AzSubscription
$date = $(get-date -format yyyy-MM-ddTHH-mm)
#$subs = Get-AzSubscription -SubscriptionName "s-sis-eu-nonprod-01"

###################################################################

$VmCPU_Report = [System.Collections.ArrayList]::new()

foreach ($sub in $subs.Name)
{
Select-AzSubscription -Subscription $sub
Write-Host "We are checking $sub" -BackgroundColor DarkGreen
Select-AzSubscription -Subscription "$sub"
$vms = Get-AzVM

# Loop through the VMs and display CPU and RAM details
foreach ($vm in $vms) {
    $vmName = $vm.Name
    $size = $vm.HardwareProfile.VmSize
    $size = get-azvmsize -Location $vm.location |where-object {$_.Name -eq $size}
    $SizeName = $size.Name
    $NumberOfCores = $size.NumberOfCores
    $MemoryInMB = $size.MemoryInMB / 1024
    Write-Host "$vmName |$SizeName|$NumberOfCores| $MemoryInMB"

    [void]$VmCPU_Report.Add([PSCustomObject]@{
    vmName = $Vmname
    sub = $sub
    SizeName = $SizeName
    NumberOfCores = $NumberOfCores
    MemoryInMB = $MemoryInMB
})
}
}
$report = 'VM_CPU_Report'+"$date"+'.csv'
$VmCPU_Report | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $Report