
#$(Get-AzAdvisorRecommendation -Category Cost | Where-Object {$_.impactedfield -eq "Microsoft.Compute/virtualMachines"}).ImpactedValue
Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$Recommendation = Get-AzAdvisorRecommendation -Category Cost | Where-Object {$_.impactedfield -eq "Microsoft.Compute/virtualMachines"} | select -ExpandProperty ExtendedProperties
$vm_affected = $Recommendation.roleName
$current_vm_size = $Recommendation.currentSku
$targe_vm_size = $Recommendation.targetSku
[int]$i = 0

Foreach ($Vm in $vm_affected)
{ 
    Write-output "Checking $VM" >> "C:\Users\ventoa1\OneDrive\Vm_Size_report_v1.txt"
    #Write-output $vm_affected[$i] >> "C:\Users\ventoa1\OneDrive\Vm_Size_report_v1.txt"
    Write-output "Current Sku VM Size:">> "C:\Users\ventoa1\OneDrive\Vm_Size_report_v1.txt"
    Write-output $current_vm_size[$i] >> "C:\Users\ventoa1\OneDrive\Vm_Size_report_v1.txt"
    Write-output "Recommended Sku VM Size:">> "C:\Users\ventoa1\OneDrive\Vm_Size_report_v1.txt"
    Write-output $targe_vm_size[$i] >> "C:\Users\ventoa1\OneDrive\Vm_Size_report_v1.txt"
    Write-output "" >> "C:\Users\ventoa1\OneDrive\Vm_Size_report_v1.txt"
    $i = $i +1
    
    $tags = Get-AzTag -resourceid $(get-azvm -name $vm).id
    $email = $tags.Properties.TagsProperty.technicalcontact
    Write-output "$vm,$email" >> "C:\Users\ventoa1\OneDrive\Vm_Email.txt"


}