# Windows Update for Windows Servers
# Update: Exclude down servers from update process #2

$Serverlist = Get-Content -Path "C:\Users\admbonada\Desktop\scripts\Serverlist.txt"
$Source = "C:\temp\updatenow.ps1"
$Destination = "C$\temp\"

foreach ($Server in $Serverlist) {

if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {

$OSVersion = (Get-WmiObject Win32_Operatingsystem -ComputerName $Server -Property Caption).Caption

    if ($OSVersion -eq "Microsoft Windows Server 2016 Standard") {
    
    Write-Host "Checking for updates in $server" -ForegroundColor Green
    Invoke-Command -ComputerName $Server -ScriptBlock {C:\Windows\system32\usoclient StartScan}
    
    } else {

    Write-Host "Checking for updates in $server" -ForegroundColor Green
    Invoke-Command -ComputerName $Server -ScriptBlock {C:\Windows\system32\wuauclt /detectnow}
    }
   
} else {
Write-Host "Server $Server is down" -ForegroundColor Red
}
}


foreach ($Server in $Serverlist) {

if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {

$OSVersion = (Get-WmiObject Win32_Operatingsystem -ComputerName $Server -Property Caption).Caption
    if ($OSVersion -eq "Microsoft Windows Server 2016 Standard") {

    Write-Host "Installing updates in $server" -ForegroundColor Green
    Invoke-Command -ComputerName $Server -ScriptBlock {C:\Windows\system32\usoclient StartInstall} #this does not install the updates

    } else {
    
    $Destination = "C$\temp"

    Write-Host "Installing updates in $server" -ForegroundColor Green
    Copy-Item $Source -Destination \\$Server\$Destination
    Invoke-Command -ComputerName $Server -ScriptBlock {C:\temp\updatenow.ps1}
    #Remove-Item "\\$Server\$Destination\updatenow.ps1"
    }
   
} else {
Write-Host "Server $Server is down" -ForegroundColor Red
}
}