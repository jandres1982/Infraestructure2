$date = Get-Date
$dt = $date.AddMinutes(1)
$hostname = hostname
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File C:\provision\Schindler\add_admin_group\add_admin_group.ps1"
$Trigger = New-ScheduledTaskTrigger -Once -At $dt
$Settings = New-ScheduledTaskSettingsSet
#$STPrin = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$STPrin = New-ScheduledTaskPrincipal -UserId "$hostname\ldmsosd" -RunLevel Highest
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $STPrin
Register-ScheduledTask -TaskName 'Local Admin Group' -InputObject $Task
SCHTASKS /change /TN "Local Admin Group" /RU ldmsosd /RP Newsetup1234 /RL HIGHEST
start-sleep 2
Start-ScheduledTask -TaskName 'Local Admin Group'
#schtasks /change /tn 'Join Domain Test Task' /ru "NT AUTHORITY\SYSTEM"
#schtasks /change /tn 'Join Domain Test Task' /ru "ldmsosd"