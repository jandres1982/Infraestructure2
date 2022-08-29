param (
[Parameter(Mandatory = $false)]
[string]$vm,
[Parameter(Mandatory = $false)]
[string]$sub
)

$automationAccountName = "aa-prod-monitoring-01"
$ResourceGroupName = "rg-cis-prod-monitoring-01"
New-AzAutomationSchedule -AutomationAccountName $automationAccountName -Name "Schedule" -StartTime "13/9/2022 11:00:00 PM +00:00" -ResourceGroupName $ResourceGroupName -OneTime

$Schedule = Get-AzAutomationSchedule -ResourceGroupName $ResourceGroupName -AutomationAccountName $automationAccountName -Name "Schedule"
#@{"vm"="shhwsr1849";"sub"="s-sis-eu-nonprod-01"}
$vm = "shhwsr1849"
$sub = "s-sis-eu-nonprod-01"
$runbookName = "Snapshots_Schedule"
$data = @{"vm"="shhwsr1849";"sub"="s-sis-eu-nonprod-01"}
$automationAccountName = "aa-prod-monitoring-01"
$ResourceGroupName = "rg-cis-prod-monitoring-01"
Register-AzAutomationScheduledRunbook –AutomationAccountName $AutomationAccountName –RunbookName $runbookName –ScheduleName $Schedule.Name –Parameters $data -ResourceGroupName $ResourceGroupName