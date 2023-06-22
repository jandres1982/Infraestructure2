# Updated July 11 2022
Remove-Item -Path C:\Windows\Temp\EPM_Logs -Force -Recurse -ErrorAction SilentlyContinue

#Sets some needed variables
$Logpath = [Environment]::GetEnvironmentVariable('LDMS_HOME') + 'log\*.*'
$Provlog = [Environment]::GetEnvironmentVariable('LDMS_HOME') + 'log\provisioning\*.*'
$LDMSHOME = [Environment]::GetEnvironmentVariable('LDMS_HOME')
$PolicyInfo = [Environment]::GetEnvironmentVariable('LDMS_HOME') + 'Landesk\files\ClientPolicies\*.*'

#Creates the temp dir(s) where files are initially copied to
mkdir -Path C:\Windows\Temp\EPM_Logs\Managementsuite_Logs -ErrorAction SilentlyContinue
mkdir -Path C:\Windows\Temp\EPM_Logs\Managementsuite_Logs\provisioning -ErrorAction SilentlyContinue
mkdir -Path C:\Windows\Temp\EPM_Logs\ProgramDataLogs -ErrorAction SilentlyContinue

#Copies first set of logs from ldlogon\log and programdata 
Copy-Item -Path $Logpath -Destination C:\Windows\Temp\EPM_Logs\Managementsuite_Logs -ErrorAction SilentlyContinue
Copy-Item -Path $Provlog -Destination C:\Windows\Temp\EPM_Logs\Managementsuite_Logs\provisioning -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\ProgramData\LANDesk\Log\' -Destination C:\Windows\Temp\EPM_Logs\ProgramDataLogs -Recurse -Container -ErrorAction SilentlyContinue

#Grabs the most recent HTTPERR logs
mkdir -Path C:\Windows\Temp\EPM_Logs\HTTPERR\ -ErrorAction SilentlyContinue
$source = 'C:\Windows\System32\LogFiles\HTTPERR'
$destination = 'C:\Windows\Temp\EPM_Logs\HTTPERR\'
@(Get-ChildItem $source -Filter *.log | Sort LastWriteTime -Descending)[0,1,2,3,4,5] | % { Copy-Item -path $_.FullName -destination $destination -force}

#Gathers the event viewer logs for application and system
$logFileName = "Application"
$path = "C:\windows\temp\EPM_Logs\EventViewer" 
$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName)
$path = "C:\windows\temp\EPM_Logs\EventViewer"
$logFileName = "System"
$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName)

#Grabs some registry information for EPM + schannel reg information
mkdir -Path C:\Windows\Temp\EPM_Logs\RegistryInfo -ErrorAction SilentlyContinue
Reg export 'HKEY_LOCAL_MACHINE\SOFTWARE\LANDesk\ManagementSuite\' C:\Windows\Temp\EPM_Logs\RegistryInfo\CoreInfo.log
Reg export 'HKEY_LOCAL_MACHINE\SOFTWARE\LANDesk\ManagementSuite\LogOptions' C:\Windows\Temp\EPM_Logs\RegistryInfo\LoggingOptions.log
Reg export 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL' C:\Windows\Temp\EPM_Logs\RegistryInfo\SchannelInfo.log

#Grabs certificate information and other information to help identify certificate related issues
mkdir -Path C:\Windows\Temp\EPM_Logs\CertificateInfo -ErrorAction SilentlyContinue
Get-Childitem cert:\LocalMachine\root -Recurse | Where-Object {$_.Issuer -ne $_.Subject} | Format-List * | Out-File C:\Windows\Temp\EPM_Logs\CertificateInfo\Non-SelfsignedCerts.log
Get-ChildItem cert:\LocalMachine\root -Recurse | where { $_.notafter -le (get-date).AddDays(30) } | select notafter, subject, issuer, thumbprint | Out-File C:\Windows\Temp\EPM_Logs\CertificateInfo\ExpriringCerts.log
dir "C:\Program Files\LANDesk\Shared Files\keys" | Out-File -filepath C:\Windows\Temp\EPM_Logs\CertificateInfo\Shared_Files_Keys_Info.txt -ErrorAction SilentlyContinue
Get-ChildItem Cert:\LocalMachine\Root\ -Recurse | where{$_.Issuer -like '*LANDesk*'} | fl * | Out-File -filepath C:\Windows\Temp\EPM_Logs\CertificateInfo\EPM_Certs_In_Trusted_Root.txt -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files\LANDesk\Shared Files\keys\*.0' -Destination C:\Windows\Temp\EPM_Logs\CertificateInfo -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files\LANDesk\Shared Files\keys\protect.ini' -Destination C:\Windows\Temp\EPM_Logs\CertificateInfo -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files\LANDesk\Shared Files\keys\*.log' -Destination C:\Windows\Temp\EPM_Logs\CertificateInfo -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Program Files\LANDesk\Identity Server\web.config' -Destination C:\Windows\Temp\EPM_Logs\CertificateInfo\Identity_Server_Web_Config.config -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\ProgramData\LANDesk\ServiceDesk\My.IdentityServer\Logs\*.log'  -Destination C:\Windows\Temp\EPM_Logs\CertificateInfo\ -ErrorAction SilentlyContinue
dir "$LDMSHOME\ldlogon\*.0" | Out-File -filepath C:\Windows\Temp\EPM_Logs\CertificateInfo\PublicCertsInLDLogon.txt -ErrorAction SilentlyContinue

#Grabs Web Console 2.0 logs
mkdir -Path C:\Windows\Temp\EPM_Logs\WebConsoleLogs -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\ProgramData\Ivanti\ManagementSuite\WebConsole\*.log'  -Destination C:\Windows\Temp\EPM_Logs\WebConsoleLogs\ -ErrorAction SilentlyContinue

#Grabs a bunch of info from the core itself such as a running process list, services, systeminfo, volume info, checks CRL/Authenticode for LDINV32.exe 
#SMB share access info for LDMAIN share, and checks for policies with a potentially bad interval setting
Get-Process | Out-File -filepath C:\Windows\temp\EPM_Logs\RunningProcesses.log -ErrorAction SilentlyContinue
Get-WmiObject win32_service | Format-Table state, name, startname, startmode | Out-File -filepath C:\Windows\Temp\EPM_Logs\ServicesInfo.log -ErrorAction SilentlyContinue
Systeminfo | Out-File -filepath C:\Windows\Temp\EPM_Logs\System_Info.log -ErrorAction SilentlyContinue
Get-Volume | Out-File -filepath C:\Windows\Temp\EPM_Logs\Drive_Information.log -ErrorAction SilentlyContinue
Get-CimInstance -ClassName Win32_LogicalDisk | Where Drivetype -eq 3 | Select-Object -Property DeviceID,@{'Name' = 'FreeSpace (GB)'; Expression= { [int]($_.FreeSpace / 1GB) }} | Out-File -filepath C:\Windows\Temp\EPM_Logs\Available_HDD_Space.txt -ErrorAction SilentlyContinue
Get-AuthenticodeSignature -FilePath "$LDMSHOME\LDInv32.exe" | Out-File -filepath C:\Windows\Temp\EPM_Logs\Authenticode_Check.log -ErrorAction SilentlyContinue
Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue | Out-File -filepath C:\Windows\Temp\EPM_Logs\InstalledAV.log -ErrorAction SilentlyContinue
Get-SmbShareAccess -Name "ldmain" | Out-File C:\Windows\Temp\EPM_Logs\SMB_Share_Info.log -ErrorAction SilentlyContinue
icacls "$LDMSHOME".trim('\') | Out-File C:\Windows\Temp\EPM_Logs\ICACLS_Output.log -ErrorAction SilentlyContinue
Select-String -Path $PolicyInfo -Pattern '<Interval>Monthly</Interval>','<Interval>Weekly</Interval>','<Interval>Daily</Interval>','<Interval>Hourly</Interval>' | Out-File -filepath C:\Windows\Temp\EPM_Logs\Tasks_With_Bad_Client_Frequency.log -ErrorAction SilentlyContinue

#Grabs 2 logs that are not stored in the normal log location
Copy-Item -Path 'C:\Windows\SysWOW64\residentagent.log' -Destination C:\Windows\Temp\EPM_Logs\residentagent.log -ErrorAction SilentlyContinue
Copy-Item -Path 'C:\Windows\SysWOW64\servicehost.log' -Destination C:\Windows\Temp\EPM_Logs\servicehost.log -ErrorAction SilentlyContinue

#Resests IIS so the logs are dumped from memory to the IIS log then gathers the most recent IIS logs. Then starts IIS again.
mkdir -Path C:\Windows\Temp\EPM_Logs\IISLog\ -ErrorAction SilentlyContinue
IISRESET -stop
$IISsource = 'C:\inetpub\logs\LogFiles\W3SVC1'
$IISdestination = 'C:\Windows\Temp\EPM_Logs\IISLog\'
@(Get-ChildItem $IISsource -Filter *.log | Sort LastWriteTime -Descending)[0,1,2,3,4,5] | % { Copy-Item -path $_.FullName -destination $IISdestination -force}
IISRESET -start

#Zip Up logs. If using an older version of powershell or .NET you will need to manually copy the logs
if (($PSVersionTable.PSVersion).Major -ge 5){
    Compress-Archive -Path C:\Windows\temp\EPM_Logs -DestinationPath ('C:\programdata\LANDesk\All_Zipped_Logs' + (get-date -Format yyyyMMdd) + '.zip') -Force
}else {
    try{
        Add-Type -Assembly "System.IO.Compression.FileSystem"
        [IO.Compression.ZipFile]::CreateFromDirectory('C:\Windows\temp\EPM_Logs', 'C:\programdata\LANDesk\All_Zipped_Logs' + (get-date -Format yyyyMMdd-HHmm) + '.zip', "Optimal", $true)    
    }
    catch{
        throw 'Powershell version 5.0 or greater, or Minimum .NET Framework 4.5 required.  Manually zip files in "C:\Windows\Temp\EPM_Logs"'
    }
}