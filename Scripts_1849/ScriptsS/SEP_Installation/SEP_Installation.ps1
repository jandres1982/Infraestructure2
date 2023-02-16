#This script can be used to start/stop/restart services on multiple servers.
#Modify on your needs....

#Get the server list 
$servers = Get-Content "D:\Scripts\Schindler\SEP_Service_Stop\Servers.txt"

$creds = Get-Credential
 
Foreach ($s in $servers){
    Invoke-Command -credential $creds -computer $s -ScriptBlock { 
        & '\\shhwsr1123\e$\Agents\SEP_14.0.3876.1100\setup.exe'
    }
}