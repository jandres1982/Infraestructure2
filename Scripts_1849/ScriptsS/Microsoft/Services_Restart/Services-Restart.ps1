#This script can be used to start/stop/restart services on multiple servers.
#Modify on your needs....

#Get the server list 
$servers = Get-Content .\Servers.txt 

$service1 = "vmvss"
$service2 = "VMtools"

#Run the commands for each server in the list

$creds = Get-Credential
 
Foreach ($s in $servers) 
{   
Invoke-Command -credential $creds -computer $s -ScriptBlock {
       Get-Service $using:service1 | Stop-Service -Force -ErrorAction SilentlyContinue
       Get-Service $using:service2 | Restart-Service -Force -ErrorAction SilentlyContinue
       Start-Sleep 10
       $status2 = (get-Service $using:service2).status
       if ($status2 -notlike "Running") {
           Start-Sleep 10
           Start-Service $using:service2 -ErrorAction SilentlyContinue
           }
       $status2new = (get-Service $using:service2).status
       Write-Host "$using:s - $using:service2 - $status2new"
       }
} 
