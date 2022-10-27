param (
[Parameter(Mandatory = $false)]
[string]$vm,
[Parameter(Mandatory = $false)]
[string]$date,
[Parameter(Mandatory = $false)]
[string]$email,
[Parameter(Mandatory = $false)]
[string]$sub
)

$Service_account = "$(AzServAcc)"
$Service_pw = "$(AzServPw)"

$date = Get-Date
$dt = $date.AddMinutes(5)
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File D:\Snapshots\Scripts\Snapshots_v1.ps1"
$taskname = "Snapshots_DevOps_$vm"
$Trigger = New-ScheduledTaskTrigger -Once -At $dt
$Settings = New-ScheduledTaskSettingsSet
Register-ScheduledTask -TaskName $taskname `
                       -TaskPath "\Snapshots" `
                       -Action $Action `
                       -User $Service_account `
                       -Password $Service_pw `
                       -Trigger $trigger `
                       -Settings $Settings `
                       -RunLevel Highest -Force
#start-sleep 3
#Start-ScheduledTask -TaskName "Snapshots_DevOps_$vm"
