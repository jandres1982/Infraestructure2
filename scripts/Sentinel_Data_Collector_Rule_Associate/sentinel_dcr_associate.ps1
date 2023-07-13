# Source info webpage https://learn.microsoft.com/en-us/powershell/module/az.monitor/new-azdatacollectionruleassociation?view=azps-10.1.0
$dcr = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-sentinel-01/providers/Microsoft.Insights/dataCollectionRules/Windows_Security_Events"
$subs = @("s-sis-eu-nonprod-01","s-sis-am-nonprod-01","s-sis-ch-nonprod-01","s-sis-ch-prod-01","s-sis-ap-prod-01","s-sis-am-prod-01")

foreach ($sub in $subs)
{
    Set-AzContext -Subscription $sub
    $vms = Get-AzVm | Where-Object {$_.StorageProfile.osDisk.osType -eq 'Windows'}
    foreach ($vm in $vms)
    {
        New-AzDataCollectionRuleAssociation -TargetResourceId $vm.Id -AssociationName "dcrAssoc" -RuleId $dcr
    }

}