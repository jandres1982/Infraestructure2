
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

cmd.exe /c 'reg delete "HKLM\SOFTWARE\VMware, Inc." /f'
cmd.exe /c 'reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{69133897-C853-451B-A8D1-E563B3C6A83D} /f'