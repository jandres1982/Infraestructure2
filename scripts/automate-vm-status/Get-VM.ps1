Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'}

Select-AzSubscription -Subscription "s-sis-eu-prod-01"
$VM_EU_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'}

Select-AzSubscription -Subscription "s-sis-ap-prod-01"
$VM_AP = $(get-azvm).name | where-object {$_ -like '*wsr*'}

Select-AzSubscription -Subscription "s-sis-am-prod-01"
$VM_AM_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'}

Select-AzSubscription -Subscription "s-sis-am-nonprod-01
$VM_AM_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'}