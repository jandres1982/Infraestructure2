Function Set-WSUS
{
Write-Output 'Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate]
"ElevateNonAdmins"=dword:00000000
"WUServer"="http://shhwsr1238.global.schindler.com:8530"
"WUStatusServer"="http://shhwsr1238.global.schindler.com:8530"
"UpdateServiceUrlAlternate"=""
"TargetGroupEnabled"=dword:00000001
"TargetGroup"="SERVERS-PROD"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU]
"NoAUAsDefaultShutdownOption"=dword:00000001
"ScheduledInstallEveryWeek"=dword:00000001
"AutoInstallMinorUpdates"=dword:00000000
"DetectionFrequencyEnabled"=dword:00000001
"DetectionFrequency"=dword:00000001
"RebootWarningTimeoutEnabled"=dword:00000000
"NoAUShutdownOption"=dword:00000001
"RebootRelaunchTimeoutEnabled"=dword:00000000
"UseWUServer"=dword:00000001
"AlwaysAutoRebootAtScheduledTime"=dword:00000001
"AlwaysAutoRebootAtScheduledTimeMinutes"=dword:0000000f
"NoAutoUpdate"=dword:00000000
"AUOptions"=dword:00000004
"ScheduledInstallDay"=dword:00000001
"ScheduledInstallTime"=dword:00000008' >> C:\provision\WSUS.reg
cmd.exe /c "reg import C:\provision\WSUS.reg"
}
Set-WSUS