$sub = "s-sis-am-nonprod-01"
Select-AzSubscription -Subscription "$sub"
az account set --subscription "$sub"
$vms = get-azvm
$vm_report = [System.Collections.ArrayList]::new()
 foreach ($vm in $vms.name) 
 {
    $vm = get-azvm -name $vm
    write-output "$vm"
      [void]$vm_report.Add([PSCustomObject]@{
         VM_Name = $vm.Name
         VM_Location = $vm.Location
         VM_ResourceGroupName = $vm.ResourceGroupName
     }) 
 } #foreach ($vm in $vms) 
#}
$report = 'c:\temp\VM_Report.csv'
$vm_report | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $Report