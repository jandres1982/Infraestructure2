clear-host
$computers = gc "D:\Repository\Working\Antonio\Disable_Windows_Update\computers.txt" #Variable to define Servers to be added.
$destination = "C$\temp\"
foreach ($computer in $computers) {#For each Server Selected in the Computers.txt file
if ((Test-Path -Path \\$computer\$destination)) { #Verify if is reachable 
#$SrvName = Read-Host -Prompt 'Input your service name, for example SNMP'
$SrvName = "wuauserv"
Write-host " "
#Test-Boolean {Get-Service -Name $SrvName}
Write-Host "Current Status:" 
Get-Service -Name $SrvName -ComputerName $computer 

Set-Service wuauserv -ComputerName $computer -StartupType Automatic

sleep 2

Get-Service -Name $SrvName -ComputerName $computer | Start-Service



Write-host "Please wait 1 second"
sleep 1
Write-host "Done!"
Write-host " "
Write-Host "After Start/Automatic Status:" 
Get-service -Name $SrvName -ComputerName $computer

}
else {
Write-host "Host not recheable"
}
} 
