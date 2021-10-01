Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$(get-azvm).name | where-object {$_ -like '*wsr*'}

Select-AzSubscription -Subscription "s-sis-eu-prod-01"
$(get-azvm).name | where-object {$_ -like '*wsr*'}