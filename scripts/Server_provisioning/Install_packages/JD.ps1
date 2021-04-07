#$jd_User = "svcshhldmssosd"
#$PW = #"76492d1116743f0423413b16050a5345MgB8AFUASQAwAFQASQBlAFkAVQBwAEEAcQA0AFQAVABMAGwAVgBpAE0ASQBRAEEAPQA9AHwAMwBlADYAMgAyAGYAMwAyAGMAZgAwADgAMQA3AGIAZgBhAGEAYwA1ADgAMgA3ADMAOQBhADgAOQAxADUAYwBiADQAMwBhADkAMwBmAGMAMgA1ADcAOQBmAGUAYQAwAGUAYgA1AGUAZQBhADQAZgAwAGIANQBjAGYAOQBmADQAOAA="
#$Key = (3, 4, 2, 3, 56, 34, 254, 222, 1, 1, 2, 23, 42, 54, 33, 233, 1, 34, 2, 7, 6, 5, 35, 43)
#$password = $PW | ConvertTo-SecureString -key $key
#$domain = "global.schindler.com"
#[pscredential]$credObject = New-Object System.Management.Automation.PSCredential($jd_User, $password)
#Add-Computer -DomainName $domain -Credential $credObject
$date = Get-Date
$dt = $date.AddMinutes(1)
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument -ExecutionPolicy Bypass -file "C:\provision\Schindler\JD\JDG.ps1"
$Trigger = New-ScheduledTaskTrigger -Once -At $dt
$Settings = New-ScheduledTaskSettingsSet
$STPrin = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -Principal $STPrin
Register-ScheduledTask -TaskName 'Join Domain' -InputObject $Task
schtasks /change /tn 'Join Domain' /ru "NT AUTHORITY\SYSTEM"