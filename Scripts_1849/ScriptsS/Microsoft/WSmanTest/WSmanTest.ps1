#Modify on your needs....

#Get the server list 
$servers = Get-Content .\Servers.txt 

#Run the commands for each server in the list
 
Foreach ($s in $servers) 
{   
if (Test-wsman -ComputerName $s -ErrorAction Ignore) {
Write-Host "$s - OK" -BackgroundColor DarkGreen
}
else {Write-Host "$s - NOT WORKING" -BackgroundColor RED}
} 
