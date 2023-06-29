
$date = $(get-date -format yyyy-MM-ddTHH-mm)

$logs = "C:\temp\vmtools_removal_logs_$date.txt"

$VMwareServices = Get-Service | Where-Object { $_.DisplayName -like "*VMware*" }
foreach ($service in $VMwareServices) {

    Stop-Service -Name $service.name
    Set-Service -StartupType Disabled -Name $service.Name
    Get-Service | Select-Object -Property * | Where-Object { $_.DisplayName -like "*VMware*" } >> $logs
}

$paths = @("C:\Program Files\VMware"; "C:\Program Files\Common Files\VMware"; "C:\ProgramData\VMware")


Foreach ($path in $paths) {
    if (Test-Path $path) {
        Remove-Item $Path -Recurse -force -ErrorAction SilentlyContinue
    }
    else {
        Write-Output "$path cannot be found, please check" >> $logs
    }
}


Write-Output "Minimum 2 Operations need to be successfully completed to safe remove the Registry Key Values" >> $logs

if (test-path "HKLM:\SOFTWARE\VMware, Inc.")
{
cmd.exe /c 'reg delete "HKLM\SOFTWARE\VMware, Inc." /f' >> $logs
}

##
if (test-path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4FE02FF2-2194-4E1D-8B04-F934655966F9}")
{
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4FE02FF2-2194-4E1D-8B04-F934655966F9} /f' >> $logs
Write-Output "VMwareTools Removed version: 11.3.0" >> $logs
#version: 11.3.0
}

##
if (test-path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{69133897-C853-451B-A8D1-E563B3C6A83D}")
{
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{69133897-C853-451B-A8D1-E563B3C6A83D} /f' >> $logs
Write-Output "VMwareTools Removed version: 11.1.1" >> $logs
#version: 11.1.1
}

##
if (test-path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{742FCBAF-EE5D-48B2-9E95-DA0513B79570}")
{
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{742FCBAF-EE5D-48B2-9E95-DA0513B79570} /f' >> $logs
Write-Output "VMwareTools Removed version: 11.0.1" >> $logs
#version: 11.0.1
}

##
if (test-path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F32C4E7B-2BF8-4788-8408-824C6896E1BB}")
{
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F32C4E7B-2BF8-4788-8408-824C6896E1BB} /f' >> $logs
Write-Output "VMwareTools Removed version: 10.3.5" >> $logs
#version: 10.3.5
}

##
if (test-path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{748D3A12-9B82-4B08-A0FF-CFDE83612E87}")
{
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{748D3A12-9B82-4B08-A0FF-CFDE83612E87} /f' >> $logs
Write-Output "VMwareTools Removed version: 10.3.2" >> $logs
#version: 10.3.2
}

##
if (test-path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{092CAFE8-7A43-4C32-82C6-A5547F93417F}")
{
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{092CAFE8-7A43-4C32-82C6-A5547F93417F} /f' >> $logs
Write-Output "VMwareTools Removed version: 10.2.1" >> $logs
#version: 10.2.1
}

##
if (test-path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{7CFC363A-72CE-409C-97C2-E497A1D831FC}")
{
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{7CFC363A-72CE-409C-97C2-E497A1D831FC} /f' >> $logs
Write-Output "VMwareTools Removed version: 10.1.15" >> $logs
#version: 10.1.15
}

##
if (test-path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{7595A850-FE4D-4273-84FA-9CC1068AFF7A}")
{
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{7595A850-FE4D-4273-84FA-9CC1068AFF7A} /f' >> $logs
Write-Output "VMwareTools Removed version: 10.0.9" >> $logs
#version: 10.0.9
}