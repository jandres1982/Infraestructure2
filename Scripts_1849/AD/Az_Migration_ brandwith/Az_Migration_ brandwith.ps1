New-NetQosPolicy -Name "ThrottleReplication" -AppPathNameMatchCondition "GatewayWindowsService.exe" -ThrottleRateActionBitsPerSecond 1MB

#Replace with an account part of the local Administrators group
$User = "localVmName\userName"

#Set the task names
$ThrottleBandwidthTask = "ThrottleBandwidth"
$IncreaseBandwidthTask = "IncreaseBandwidth"

#Create a directory to host PowerShell scaling scripts
if (!(Test-Path "C:\ReplicationBandwidthScripts"))
{
 New-Item -Path "C:\" -Name "ReplicationBandwidthScripts" -Type Directory
}

#Set your minimum bandwidth to be used during replication by changing the ThrottleRateActionBitsPerSecond parameter
#Currently set to 10 MBps
New-Item C:\ReplicationBandwidthScripts\ThrottleBandwidth.ps1
Set-Content C:\ReplicationBandwidthScripts\ThrottleBandwidth.ps1 'Set-NetQosPolicy -Name "ThrottleReplication" -ThrottleRateActionBitsPerSecond 10MB'
$ThrottleBandwidthScript = "C:\ReplicationBandwidthScripts\ThrottleBandwidth.ps1"

#Set your maximum bandwidth to be used during replication by changing the ThrottleRateActionBitsPerSecond parameter
#Currently set to 1000 MBps
New-Item C:\ReplicationBandwidthScripts\IncreaseBandwidth.ps1
Set-Content C:\ReplicationBandwidthScripts\IncreaseBandwidth.ps1 'Set-NetQosPolicy -Name "ThrottleReplication" -ThrottleRateActionBitsPerSecond 1000MB'
$IncreaseBandwidthScript = "C:\ReplicationBandwidthScripts\IncreaseBandwidth.ps1"

#Timezone set on the Azure Migrate Appliance (VM) will be used; change the frequency to meet your needs
#In this example, the bandwidth is being throttled every weekday at 8:00 AM local time
#The bandwidth is being increased every weekday at 6:00 PM local time
$ThrottleBandwidthTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 8:00am
$IncreaseBandwidthTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 6:00pm

#Setting the task action to execute the scripts
$ThrottleBandwidthAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-executionpolicy bypass -noprofile -file $ThrottleBandwidthScript" 
$IncreaseBandwidthAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-executionpolicy bypass -noprofile -file $IncreaseBandwidthScript" 

#Creating the Scheduled tasks
Register-ScheduledTask -TaskName $ThrottleBandwidthTask -Trigger $ThrottleBandwidthTrigger -User $User -Action $ThrottleBandwidthAction -RunLevel Highest -Force
Register-ScheduledTask -TaskName $IncreaseBandwidthTask -Trigger $IncreaseBandwidthTrigger -User $User -Action $IncreaseBandwidthAction -RunLevel Highest -Force