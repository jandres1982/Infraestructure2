clear-host
$date_day = date -Format "yyyy_MM_dd"; 
$date_hour = date -format HH_mm;
$date = "Day_"+$date_day+"_At_"+$date_hour;

$computers = gc "D:\Repository\Working\Antonio\Disable_Windows_Update\computers.txt" #Variable to define Servers to be added.
$destination = "C$\temp\"
foreach ($computer in $computers) {#For each Server Selected in the Computers.txt file
if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable 
#$SrvName = Read-Host -Prompt 'Input your service name, for example SNMP'
$SrvName = "wuauserv"
#Write-host " "
#Test-Boolean {Get-Service -Name $SrvName}
#Write-Host "Current Status:" 
#Get-Service -Name $SrvName -ComputerName $computer 
Get-Service -Name $SrvName -ComputerName $computer | Stop-Service
sleep 2
Set-Service wuauserv -ComputerName $computer -StartupType Disabled
sleep 1

$Result = invoke-command -ComputerName $computer -ScriptBlock {Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "C:\Windows\SoftwareDistribution.old"} -ErrorAction Ignore

If ($?)
{Write-host "Folder Renamed"
}
Else{
Write-host "Folder failed to Rename"
}


Write-host "*****"
Write-Host "After Stop/Disable Status:" 

Get-Service -Name $SrvName -computername $computer | Select MachineName,Name"",Status,StartType


}
else {
Write-host "Host $computer not recheable"
Write-Output "Host $computer not recheable" >> "D:\Repository\Working\Antonio\Disable_Windows_Update\Logs\Running_$date.txt"
}
} 
