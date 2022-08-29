$URL = 'https://09108026-1ae8-4628-a525-1b65ce0f41a6.webhook.ne.azure-automation.net/webhooks?token=OLlNsdGyLnzsFephdqiVfZNs4Py67HYEfdFWavAKN8s%3d'
#$body = ConvertTo-Json -InputObject $bodymsg
#$body = @(
#@{ Message="$Parameters"+"$Template_2019"}
#)
#$body_1 = $Template_2019
#$body = <vm>,<sub>,<retain>,<schedule>
$body = Write-Output "zzzwsr0010","s-sis-eu-nonprod-01","30-08-2022","26-08-2022"
$header = @{message = "Send Variables"}
#$header_1 = @{ message = "Send Template"}
$response = Invoke-RestMethod -Method Post -uri $URL -Body $body -Headers $header

$automationAccountName = "aa-prod-monitoring-01"
$runbookName = "Snapshots_Schedule"
$scheduleName = "Snapshots_Schedule_Title"
$params = @{"vm"="shhwsr1849";"sub"="s-sis-eu-nonprod-01"}
Register-AzAutomationScheduledRunbook -AutomationAccountName $automationAccountName `
-Name $runbookName -ScheduleName $scheduleName -Parameters $params `
-ResourceGroupName "rg-cis-prod-monitoring-01"


$automationAccountName = "aa-prod-monitoring-01"
$ResourceGroupName "rg-cis-prod-monitoring-01"
$name = "Snapshots_Schedule_Title"
$StartTime = (Get-Date).AddDays(1)
New-AzAutomationSchedule `
    -AutomationAccountName $AutomationAccountName `
    -ResourceGroupName $ResourceGroupName `
    -Name $name `
    -StartTime $StartTime
New-AzureRMAutomationSchedule –AutomationAccountName AzureAutomationAccount –Name "GetData" -StartTime "01/26/2019 22:30:00" -HourInterval 1  -ResourceGroupName "AzureAutomation"



######################################################################
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
Register-AzAutomationScheduledRunbook –AutomationAccountName $AutomationAccountName –RunbookName $runbookName –ScheduleName $Schedule –Parameters $data -ResourceGroupName $ResourceGroupName
