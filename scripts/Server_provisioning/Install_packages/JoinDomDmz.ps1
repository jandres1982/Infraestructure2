$date = Get-Date
$dt = $date.AddMinutes(1)
$hostname = hostname
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File C:\provision\Schindler\JoinDom\JoinDomDmz.ps1"
$taskname = "Join Domain"
$Trigger = New-ScheduledTaskTrigger -Once -At $dt
$Settings = New-ScheduledTaskSettingsSet
Register-ScheduledTask -TaskName $taskname `
                       -TaskPath "\" `
                       -Action $Action `
                       -User 'ldmsosd' `
                       -Password 'Newsetup1234' `
                       -Trigger $trigger `
                       -Settings $Settings `
                       -RunLevel Highest -Force
start-sleep 3
Start-ScheduledTask -TaskName 'Join Domain'
#$date = Get-Date
#$dt = $date.AddMinutes(1)
#$hostname = hostname
#$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File C:\provision\Schindler\JoinDom\JoinDomGlobal.ps1"
#$Trigger = New-ScheduledTaskTrigger -Once -At $dt
#$Settings = New-ScheduledTaskSettingsSet
#$STPrin = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
#$STPrin = New-ScheduledTaskPrincipal -UserId "$hostname\ldmsosd" -RunLevel Highest
#$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $STPrin
#Register-ScheduledTask -TaskName 'Join Domain' -InputObject $Task
#SCHTASKS /change /TN "Join Domain" /RU ldmsosd /RP Newsetup1234 /RL HIGHEST
#schtasks /change /tn 'Join Domain Test Task' /ru "NT AUTHORITY\SYSTEM"
#schtasks /change /tn 'Join Domain Test Task' /ru "ldmsosd"