Install-Module -Name PowerShellGet

$sub_id = $(Get-AzSubscription -SubscriptionName s-sis-eu-prod-01).Id

New-AzUserAssignedIdentity -ResourceGroupName "rg-shh-prod-devopsvdi-01" -Name "SHHWSR2371" -Location "NorthEurope" -SubscriptionId $sub_id

$vm = Get-AzVM -ResourceGroupName "rg-shh-prod-devopsvdi-01" -Name "SHHWSR2371"

Update-AzVM -ResourceGroupName "rg-shh-prod-devopsvdi-01" -VM $vm -IdentityType "UserAssigned" -IdentityID "/subscriptions/505ead1a-5a5f-4363-9b7283eb2234a43d/resourcegroups/rg-shh-prod-devopsvdi-01/providers/Microsoft.ManagedIdentity/userAssignedIdentities/SHHWSR2371"

Update-AzVM -ResourceGroupName "rg-shh-prod-devopsvdi-01" -VM $vm