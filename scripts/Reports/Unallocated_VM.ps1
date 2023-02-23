$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01","s-sis-ch-prod-01","s-sis-ch-nonprod-01","s-sis-soc-ctitasks-prod")
#$subs = "s-sis-eu-nonprod-01"
$date = $(get-date -format yyyy-MM-ddTHH-mm)

$vmObject = [System.Collections.ArrayList]::new()

foreach ($sub in $subs)
    {
    Select-AzSubscription -Subscription "$sub"
    $vm_off = get-azvm -Status | Where-Object {$_.PowerState -clike "VM deallocated"}
    $sub = Get-AzSubscription -SubscriptionName $sub
        foreach ($vm in $vm_off)
        {
        [string]$vm_name = $vm.name
        Write-host "Working on $vm_name " -ForegroundColor Green
        [void]$vmObject.add([PSCustomObject]@{
        Subscription = $sub.name
        Name = $vm.Name
        Resource_Group = $vm.ResourceGroupName
        Location = $vm.Location
        ProvisioningState = $vm.ProvisioningState
        Operating_System = $vm.StorageProfile.OsDisk.OsType
        PowerState = $vm.PowerState
        Size = $vm.HardwareProfile.VmSize 
        OsDisk =$vm.StorageProfile.OsDisk.Count
        Tag_serviceowner = $vm.Tags.serviceowner
        Tag_applicationowner = $vm.Tags.applicationowner
        Tag_technicalcontact = $vm.Tags.technicalcontact
        Tag_kg = $vm.Tags.kg
        Tag_costcenter = $vm.Tags.costcenter
        Tag_infrastructureservice = $vm.Tags.infrastructureservice
        })
        }
    }

$report = 'VMS'+'_Unallocated_'+"$date"+'.csv'
$vmObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report