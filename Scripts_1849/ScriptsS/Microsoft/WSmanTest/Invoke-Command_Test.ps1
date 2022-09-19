#Modify on your needs....

#Get the server list 
$servers = Get-Content .\Servers.txt 

#Run the commands for each server in the list
 
Foreach ($s in $servers) 
{   
if (Test-wsman -ComputerName $s -ErrorAction Ignore) {
Invoke-Command -ComputerName $s -ScriptBlock {Write-Host $env:COMPUTERNAME -backgroundcolor DarkGreen}
}
else {Write-Host "$s - Test-WSMAN is NOT WORKING" -BackgroundColor RED}
} 
