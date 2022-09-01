param (
[Parameter(Mandatory = $false)]
[string]$vm,
[Parameter(Mandatory = $false)]
[string]$sub,
[Parameter(Mandatory = $false)]
[int]$Retention,
[Parameter(Mandatory = $false)]
[datetime]$Schedule_Time
)

$automationAccountName = "aa-prod-monitoring-01"
$ResourceGroupName = "rg-cis-prod-monitoring-01"
$vm = "shhwsr1848"
$sub = "s-sis-eu-prod-01"
$runbookName = "Snapshots_Schedule"
$Retention = "7"
$Schedule_Time =  (Get-date).AddMinutes(6)

New-AzAutomationSchedule -AutomationAccountName $automationAccountName -Name "Schedule $vm" -StartTime $Schedule_Time -ResourceGroupName $ResourceGroupName -OneTime

$Schedule = Get-AzAutomationSchedule -ResourceGroupName $ResourceGroupName -AutomationAccountName $automationAccountName -Name "Schedule $vm"
#@{"vm"="shhwsr1849";"sub"="s-sis-eu-nonprod-01"}

$data = @{"vm"="$vm";"sub"="$sub";"Retention"="$Retention";"Schedule_Time"="$Schedule_Time"}
Register-AzAutomationScheduledRunbook –AutomationAccountName $AutomationAccountName –RunbookName $runbookName –ScheduleName $Schedule.Name –Parameters $data -ResourceGroupName $ResourceGroupName