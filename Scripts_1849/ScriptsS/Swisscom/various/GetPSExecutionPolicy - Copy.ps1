#Get the server list 
$servers = Get-Content .\Serverlistpsexecutionpolicy.txt 

$list = @()
#Run the commands for each server in the list 
Foreach ($s in $servers) 
{   
$PSExecPolicy = Invoke-Command -computer $s -ScriptBlock {Get-ExecutionPolicy} | select PSComputerName,Value
$list += $PSExecPolicy
} 
$list | export-csv .\resultspsexecpolicy.csv