# Updated Jan 4th 2023

write-host "Gathering Client EPM logs"
write-host "Script Updated Jan 4th 2023"

Remove-Item -Path C:\ProgramData\LANDesk\PS1_Log_Script -Force -Recurse -ErrorAction SilentlyContinue
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\LDCLient | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\Data | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\Alert_Queue | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\Broker | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\ClientCerts | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\VulscanFolder | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\Policies | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\Provisioning | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\Windows_Temp_Folder | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\Provisioning\UnattendGC | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\EventViewer | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\EventViewer\Application_Services_Log | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\Shared_Files | Out-Null
mkdir -Path C:\ProgramData\LANDesk\PS1_Log_Script\RegistryInfo | Out-Null
New-Item -ItemType directory -Path C:\programdata\landesk\log\PXETroubleshooting -ErrorAction SilentlyContinue | Out-Null

#creates function so that we can cleanly grab the netstat info

function Get-NetworkStatistics
{
         $properties = ‘Protocol’,’LocalAddress’,’LocalPort’
         $properties += ‘RemoteAddress’,’RemotePort’,’State’,’ProcessName’,’PID’

         netstat -ano | Select-String -Pattern ‘\s+(TCP|UDP)’ | ForEach-Object {

             $item = $_.line.split(” “,[System.StringSplitOptions]::RemoveEmptyEntries)

             if($item[1] -notmatch ‘^\[::’)
             {
                 if (($la = $item[1] -as [ipaddress]).AddressFamily -eq ‘InterNetworkV6’)
                 {
                    $localAddress = $la.IPAddressToString
                    $localPort = $item[1].split(‘\]:’)[-1]
                 }
                 else
                 {
                     $localAddress = $item[1].split(‘:’)[0]
                     $localPort = $item[1].split(‘:’)[-1]
                 }

                 if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq ‘InterNetworkV6’)
                 {
                    $remoteAddress = $ra.IPAddressToString
                    $remotePort = $item[2].split(‘\]:’)[-1]
                 }
                 else
                 {
                    $remoteAddress = $item[2].split(‘:’)[0]
                    $remotePort = $item[2].split(‘:’)[-1]
                 }

                 New-Object PSObject -Property @{
                     PID = $item[-1]
                     ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name
                     Protocol = $item[0]
                     LocalAddress = $localAddress
                     LocalPort = $localPort
                     RemoteAddress =$remoteAddress
                     RemotePort = $remotePort
                     State = if($item[0] -eq ‘tcp’) {$item[3]} else {$null}
                 } | Select-Object -Property $properties
             }
         }
     }

#Grabs netstat info for port 67 and 69
Get-NetworkStatistics | Where-Object LocalPort -in "67","69" | Format-table | Out-File C:\Programdata\landesk\log\PXETroubleshooting\PXENetStat.log

#Grabs status of firewall (enabled/disabled)
Get-NetFirewallProfile | Format-table -Property Name, Enabled | Out-File C:\Programdata\landesk\log\PXETroubleshooting\FirewallStatus.log

#If firewall is enabled, check this log to see if the mtftp service is open or not
Get-NetFirewallRule -DisplayName 'LANDESK(R) PXE MTFTP Service' -ErrorAction SilentlyContinue |
Format-Table -Property DisplayName, DisplayGroup, @{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
@{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
@{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}},
@{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}},
Enabled, Profile, Direction, Action |out-file C:\Programdata\landesk\log\PXEtroubleshooting\FirewallRulesMTFTP.log -ErrorAction SilentlyContinue

#If firewall is enabled, check this log to see if the pxe service is open or not
Get-NetFirewallRule -DisplayName 'LANDESK(R) PXE Service' -ErrorAction SilentlyContinue |
Format-Table -Property DisplayName, DisplayGroup, @{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
@{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
@{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}},
@{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}},
Enabled, Profile, Direction, Action |out-file C:\Programdata\landesk\log\PXEtroubleshooting\FirewallRulesPXE.log -ErrorAction SilentlyContinue

#Shows what network adapters are enabled. 
Get-NetAdapter | out-file C:\Programdata\landesk\log\PXEtroubleshooting\AdapterCheck.log

#Copy all EPM related logs that can be used for troubleshooting various issues.
Copy-Item -Path 'C:\Program Files (x86)\LANDesk\Shared Files\*.log' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Shared_Files -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files (x86)\LANDesk\Shared Files\*.old' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Shared_Files -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files (x86)\LANDesk\Shared Files\*.txt' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Shared_Files -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\ProgramData\LANDesk\Log\' -Destination C:\ProgramData\LANDesk\PS1_Log_Script -Recurse -Container -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\ProgramData\Vulscan\' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\VulscanFolder -Recurse -Container -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\ProgramData\LANDesk\Policies\' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Policies -Recurse -Container -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files (x86)\LANDesk\Ldclient\*.log' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Ldclient -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files (x86)\LANDesk\Ldclient\data\*.log' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Data -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files (x86)\LANDesk\LDClient\Data\TaskHistory.xml' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Data -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files (x86)\LANDesk\Shared Files\cbaroot\certs\*.0' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\ClientCerts -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files (x86)\LANDesk\Shared Files\cbaroot\broker\*.*' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Broker -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files\Ivanti\Endpoint\update_statistics.xml' -Destination C:\ProgramData\LANDesk\PS1_Log_Script -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Windows\Panther\UnattendGC\Setup*' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Provisioning\UnattendGC -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\ldprovisioning\*.*' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Provisioning -Recurse -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Windows\System32\drivers\etc\host*' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\ -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Windows\debug\NetSetup.txt' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\Provisioning -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Windows\System32\winevt\Logs\*' -Destination C:\ProgramData\LANDesk\PS1_Log_Script\EventViewer\Application_Services_Log -Recurse -ErrorAction SilentlyContinue


#Copies files in the temp folder that are up to 4 days old and less than 15MBs. This is for gathering provisioning logs that are no longer available in the ldprovisioning folder 
$tempdate = (get-date).AddDays(-4)
Get-ChildItem C:\Windows\Temp\*.* | Where-Object {($_.Lastwritetime -gt $tempdate) -and ($_.Length -le 15000000)} | ForEach-Object {copy-item $_ C:\ProgramData\LANDesk\PS1_Log_Script\Windows_Temp_Folder -ErrorAction SilentlyContinue}

#Get running process list (separarate logs for command line options, CPU time, and the default Get-Process output), System information, IP info, select registry infomration related to EPM, local scheduler tasks, copy of the ldclient file list, and installed EPM services 
Get-Process | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\Process_Running.log -ErrorAction SilentlyContinue
gcim win32_process | Sort-Object Name | Select Name, ProcessId, commandline | Format-Table Name, ProcessId, commandline -AutoSize |  Out-File -width 999999 -Encoding utf8 C:\ProgramData\LANDesk\PS1_Log_Script\Process_Commandline.log -ErrorAction SilentlyContinue
Get-Process | Sort-Object ProcessName | select ProcessName, Id, TotalProcessorTime | Format-Table Id, ProcessName, TotalProcessorTime -AutoSize | Out-File  C:\ProgramData\LANDesk\PS1_Log_Script\Process_CPU_Time.log -ErrorAction SilentlyContinue
Systeminfo | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\SystemInfo.log -ErrorAction SilentlyContinue
ipconfig /all | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\Hostname_IP_Info.log -ErrorAction SilentlyContinue
cd 'C:\Program Files (x86)\LANDesk\Ldclient\' -ErrorAction SilentlyContinue
.\LocalSch.EXE /tasks | more | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\LocalSchedulerTasks.log -ErrorAction SilentlyContinue
Get-ChildItem 'C:\Program Files (x86)\LANDesk\LDClient\' -ErrorAction SilentlyContinue | ForEach-Object {$_.VersionInfo} | Format-Table | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\LDClientFileList.log -ErrorAction SilentlyContinue
Get-Service -DisplayName "*Landesk*","*Ivanti*" | Sort-Object DisplayName | Format-Table -AutoSize | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\EPM_Services.log -ErrorAction SilentlyContinue
Get-Service | Sort-Object DisplayName | Format-Table -AutoSize | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\All_Services.log -ErrorAction SilentlyContinue

#Registry Export
Reg export 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\landesk\managementsuite\WinClient\Vulscan\' "C:\ProgramData\LANDesk\PS1_Log_Script\RegistryInfo\Vulscan_Registry.log"
Reg export 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\landesk\Common Api' "C:\ProgramData\LANDesk\PS1_Log_Script\RegistryInfo\DeviceID_LANDesk.log"
Reg export 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\Intel\LANDesk\Common Api' "C:\ProgramData\LANDesk\PS1_Log_Script\RegistryInfo\DeviceID_Intel.log"
Reg export 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\OMADM' "C:\ProgramData\LANDesk\PS1_Log_Script\RegistryInfo\MDM_DeviceID.log"
Reg export 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\landesk' "C:\ProgramData\LANDesk\PS1_Log_Script\RegistryInfo\Entire_LANDesk_Registry.log"
Get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Intel\LANDesk\LDWM | Select CoreServer | Out-File C:\ProgramData\LANDesk\PS1_Log_Script\RegistryInfo\CoreServerName.log -ErrorAction SilentlyContinue

#Identifies installed AV software, checks drive space and infomration, checks authenticode status for inventory scanner, gathers powercfg.exe info (/a and /q info in same log)
Get-Volume | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\Drive_Information.log -ErrorAction SilentlyContinue
Get-CimInstance -ClassName Win32_LogicalDisk | Where Drivetype -eq 3 | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }} | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\Available_HDD_Space.log -ErrorAction SilentlyContinue
Get-AuthenticodeSignature -FilePath 'C:\Program Files (x86)\LANDesk\LDClient\LDISCN32.EXE' | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\Authenticode_Check.log -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\InstalledAV.log -ErrorAction SilentlyContinue
powercfg.exe /a | Out-File -filepath C:\ProgramData\LANDesk\PS1_Log_Script\Powercfg.log -ErrorAction SilentlyContinue
powercfg.exe /q | Add-Content C:\ProgramData\LANDesk\PS1_Log_Script\Powercfg.log -ErrorAction SilentlyContinue

#Gathers Application, System, and Security event viewer logs
$logFileName = "Application"
$path = "C:\ProgramData\LANDesk\PS1_Log_Script\EventViewer\" 
 
$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName) | Out-Null

$path = "C:\ProgramData\LANDesk\PS1_Log_Script\EventViewer\"
$logFileName = "System"

$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName) | Out-Null

$path = "C:\ProgramData\LANDesk\PS1_Log_Script\EventViewer\"
$logFileName = "Security"

$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName) | Out-Null

#zips all files if the PS version is higher than 5.0. If the computer doesn't have PS v5 then it will tell the end user that they need to zip the files manually.
if ($PSVersionTable.PSVersion.Major -ge 5) {Compress-Archive -Path C:\ProgramData\LANDesk\PS1_Log_Script -DestinationPath ('C:\programdata\LANDesk\All_Zipped_Logs_' + $env:computername + '_' + (get-date -Format MMddyyyy) + '.zip') -Force } else {write-host "Powershell version not able to zip files. Manually Zip files that were copied to the C:\ProgramData\LANDesk\PS1_Log_Script folder."}