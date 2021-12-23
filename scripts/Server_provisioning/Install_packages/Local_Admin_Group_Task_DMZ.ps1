$date = Get-Date
$dt = $date.AddMinutes(1)
$hostname = hostname
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File C:\provision\Schindler\add_admin_group\Add_Admin_Group_Dmz.ps1"
$Trigger = New-ScheduledTaskTrigger -Once -At $dt
$Settings = New-ScheduledTaskSettingsSet
$taskname = 'Local Admin Group'
Register-ScheduledTask -TaskName $taskname `
                       -TaskPath "\" `
                       -Action $Action `
                       -User 'Boss_MSRV' `
                       -Password 'Newsetup1234' `
                       -Trigger $trigger `
                       -Settings $Settings `
                       -RunLevel Highest -Force
start-sleep 3
Start-ScheduledTask -TaskName 'Local Admin Group'