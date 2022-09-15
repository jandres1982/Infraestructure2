param (
[Parameter(Mandatory = $false)]
[string]$vmName,
[Parameter(Mandatory = $false)]
[string]$sub,
[Parameter(Mandatory = $false)]
[string]$location,
[Parameter(Mandatory = $false)]
[string]$resourceGroup
)

$automationAccountName = "aa-prod-monitoring-01"
$ResourceGroupName = "rg-cis-prod-monitoring-01"
$runbookName = "Disk_Snapshots"

######################### From Devops ########################
$vmName = "tstshhwsr0343"
$sub = "s-sis-eu-nonprod-01"
$date = "15/09/2022 17:06"
$ResourceGroup = "rg-shh-test-sharepoint-01"
$location = "North Europe"
##############################################################

$Schedule_Time = $date -as [datetime]

$Snapshot_name = $vmName+"_Snapshot"
New-AzAutomationSchedule -AutomationAccountName $automationAccountName -Name $Snapshot_name -StartTime $Schedule_Time -ResourceGroupName $ResourceGroupName -OneTime

$Schedule = Get-AzAutomationSchedule -ResourceGroupName $ResourceGroupName -AutomationAccountName $automationAccountName -Name $Snapshot_name

$data = @{"vmName"="$vmName";"sub"="$sub";"location"="$location";"resourceGroup"="$resourceGroup"}
Register-AzAutomationScheduledRunbook –AutomationAccountName $AutomationAccountName –RunbookName $runbookName –ScheduleName $Schedule.Name –Parameters $data -ResourceGroupName $ResourceGroupName