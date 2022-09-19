#Get the server list 
$servers = Get-Content .\Serverlistservices.txt 

$list = @()
#Run the commands for each server in the list 
Foreach ($s in $servers) 
{   
$Services = Get-WmiObject -Class Win32_Service -ComputerName $s -ErrorAction SilentlyContinue | select __SERVER, DisplayName, State, startname #Get all Services
$list += $Services
} 
$list | export-csv .\resultsservices.csv