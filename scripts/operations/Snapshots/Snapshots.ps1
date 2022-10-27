param (
[Parameter(Mandatory = $false)]
[string]$vm,
[Parameter(Mandatory = $false)]
[string]$date,
[Parameter(Mandatory = $false)]
[string]$email
)

$Service_account = ""
$Service_pw = ""


$date = Get-Date
$dt = $date.AddMinutes(5)
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File D:\Snapshots\Scripts\Snapshots_v1.ps1"
$taskname = "Snapshots_DevOps_$vm"
$Trigger = New-ScheduledTaskTrigger -Once -At $dt
$Settings = New-ScheduledTaskSettingsSet
Register-ScheduledTask -TaskName $taskname `
                       -TaskPath "\Snapshots" `
                       -Action $Action `
                       -User 'intshhazuredevops' `
                       -Password 'uX7V,p-#-890Ia' `
                       -Trigger $trigger `
                       -Settings $Settings `
                       -RunLevel Highest -Force
start-sleep 3
Start-ScheduledTask -TaskName 'Snapshots_DevOps_$vm'
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