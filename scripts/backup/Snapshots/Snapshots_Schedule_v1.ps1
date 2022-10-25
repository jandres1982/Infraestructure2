param (
[Parameter(Mandatory = $false)]
[string]$vmName,
[Parameter(Mandatory = $false)]
[string]$sub,
[Parameter(Mandatory = $false)]
[string]$location,
[Parameter(Mandatory = $false)]
[string]$resourceGroup,
[Parameter(Mandatory = $false)]
[datetime]$date
)

$Schedule_Time = $date -as [datetime]

Write-Output "$date"
$automationAccountName = "aa-prod-monitoring-01"
$resourceGroupName = "rg-cis-prod-monitoring-01"
$runbookName = "Disk_Snapshots"

#Select-AzSubscription -Subscription "s-sis-eu-prod-01"
#Set-azContext -Subscription "s-sis-eu-prod-01"


######################### From Devops ########################
#$vmName = "tstshhwsr0343"
#$sub = "s-sis-eu-nonprod-01"
#$(date) = "15/09/2022 17:06"
#$resourceGroup = "rg-shh-test-sharepoint-01"
#$location = "North Europe"
##############################################################


$Snapshot_name = $vmName+"_Snapshot"
New-AzAutomationSchedule -AutomationAccountName $automationAccountName -Name $Snapshot_name -StartTime $Schedule_Time -ResourceGroupName $resourceGroupName -OneTime

$Schedule = Get-AzAutomationSchedule -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $Snapshot_name

$data = @{"vmName"="$vmName";"sub"="$sub";"location"="$location";"resourceGroup"="$resourceGroup";"date"="$date"}
Register-AzAutomationScheduledRunbook –AutomationAccountName $AutomationAccountName –Name $runbookName –ScheduleName $Schedule.Name –Parameters $data -ResourceGroupName $resourceGroupName