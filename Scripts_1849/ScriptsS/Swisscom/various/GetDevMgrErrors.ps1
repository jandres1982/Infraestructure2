#Get the server list 
$servers = Get-Content .\Serverlistdevmgr.txt 

$list = @()
#Run the commands for each server in the list 
Foreach ($s in $servers) 
{   
$DevMgrError = Get-WmiObject -Class Win32_PNPEntity -ComputerName $s -ErrorAction SilentlyContinue | where-object {$_.configmanagererrorcode -ne 0} | select __SERVER, name, configmanagererrorcode #Get DevMgr Errors
$list += $DevMgrError
} 
$list | export-csv .\resultsdevmgrerror.csv