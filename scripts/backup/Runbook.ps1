#variables
$Subscription = ''
$AutomationAccountName = ''
$ResourceGroupName = ''
$RunbookName = ''
$ScheduleName = ''

$SearchParameter = '' #This is the parameter you want to find to replace
$NewParameterValue = ""

$ErrorActionPreference = "Stop"

#Authenticate
$getContext = Get-AzContext 
if(!$getContext) {
   Connect-AzAccount
   }
else {
   Write-Verbose "Account already logged in." -Verbose
}

Set-AzContext -SubscriptionId  $Subscription -Verbose | Out-Null

#Find the schedule for runbook
$existingSchedule = Get-AzAutomationScheduledRunbook `
                               -AutomationAccountName $AutomationAccountName `
                               -ResourceGroupName $ResourceGroupName `
                               -RunbookName $RunbookName | Where-Object {$_.ScheduleName -eq $ScheduleName}
       
if (!$existingSchedule) { Write-Host "Could not find schedule. Check if you runbook/schedule is exists."
   Break
 }

 #Get schedule using JobScheduleId to retrieve parameters
 $getScheduleWithParameters =  Get-AzAutomationScheduledRunbook `
                                      -JobScheduleId $existingSchedule.JobScheduleId `
                                      -AutomationAccountName $AutomationAccountName `
                                      -ResourceGroupName $ResourceGroupName -Verbose 

 if (!$getScheduleWithParameters.Parameters."$SearchParameter")
 {
     Write-Host "The property $($SearchParameter) cannot be found on the schedule. Verify that the property exists and can be set."
 }
 else
 {
     $getScheduleWithParameters.Parameters."$SearchParameter" = $NewParameterValue
 }
 
 #Unlink your schedule to perform update on parameters
 Unregister-AzAutomationScheduledRunbook `
           -AutomationAccountName $AutomationAccountName `
           -Name $RunbookName `
           -ResourceGroupName $ResourceGroupName `
           -ScheduleName $ScheduleName -Force -Verbose 

 #Relink your schedule to update parameters
 Register-AzAutomationScheduledRunbook `
               -AutomationAccountName $AutomationAccountName `
               -Name $RunbookName `
               -ScheduleName $getScheduleWithParameters.ScheduleName `
               -ResourceGroupName $ResourceGroupName `
               -Parameters $getScheduleWithParameters.Parameters `
               -Verbose 
