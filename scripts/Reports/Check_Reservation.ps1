#Install Az.Reservations Module if not exists.
#Install-Module -Name Az.Reservations -Scope CurrentUser

#Start and End date to fetch consumption usage details of Azure Reservations
$startDate = '10-05-2021'
$endDate = '11-05-2022'

#List all Azure subscriptions
$subscriptionIds = Get-AzSubscription
foreach ($subscription in $subscriptionIds) {
    #Change the Subscription
    Set-AzContext -Subscription $subscription
    #Get the information of Azure Reservation consumption usage details
    $info = Get-AzConsumptionUsageDetail -StartDate $startDate -EndDate $endDate
    #Save the information to Microsoft Excel CSV files with subscription id in the name of file
    $info | Export-Csv -NoTypeInformation -Path "C:\temp\$($subscription.name).csv"
}