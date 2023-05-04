Function Send-Mail
{
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$To = $AppOwner
$CC = "antoniovicente.vento@schindler.com","alfonso.marques@schindler.com" 
#$cc = "javier.cabezudo@schindler.com"
$Subject = "Azure Vm Advisor for Cost Reduction"
$Body = @"
Dear team,

The Azure resource VM $vmName was found to be using more resources than needed. Over 30 days VM CPU was less than 20% use.

Would you mind to check the recommendations and reduce cost.

Recommendation for the VM: $Recomendation

Cost Saving after appliying the recommendation in EUR: $CostSave

Thanks,

Schindler Cloud DevOps Team

"@
Send-MailMessage -From $From -To $To -Cc $cc -Subject $Subject -Body $Body
}

$advisor = import-csv .\Advisor_2023-05-04T10_45_56.549Z.csv -Delimiter ";"
#$vms = $advisor."Resource Name" 
$vms = $advisor | Where-Object {$_."Resource Name" -like "shhwsr1999"}
#$vm = "shhwsr1999"

foreach ($vm in $vms)
{
$vmSubId =$vm."Subscription ID"
$vmName = $vm."Resource Name"
$vmRg =$vm."Resource Group"
Select-AzSubscription -SubscriptionId $vmSubId
$vmProfile = Get-azvm -Name $vmName -ResourceGroupName $vmRg
$AppOwner = $vmProfile.tags.applicationowner
$CostSave = $vm."Potential Annual Retail Cost Savings"
$Recomendation = $vm."Recommended action 1"
Send-Mail
}