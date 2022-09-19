#Get the server list 
$servers = Get-Content .\Serverlistiis.txt 

$list = @()
$errors = @()
#Run the commands for each server in the list 
Foreach ($s in $servers) 
{
if ([bool](Test-WSMan $s -ErrorAction SilentlyContinue) -eq $false) {
$IISLogLocation = "$s ERROR - WSMan-Test Failed - skipped"
$errors += $IISLogLocation
}
else{
$IISLogLocation = Get-WmiObject -Namespace root\microsoftiisv2 -class iiswebserversetting -ComputerName $s  | where-object {$_.Logfiledirectory -like "C:*"}  | select __Server, ServerComment, Logfiledirectory #Get IIS Logfile directory
$list += $IISLogLocation
}
} 
$list | export-csv .\resultsiis.csv
$errors