#Get the server list 
$servers = Get-Content .\serverlistroutescript.txt 

$list = @()
#Run the commands for each server in the list 
Foreach ($s in $servers) 
{   
$routescript = Invoke-Command -computer $s -ScriptBlock {if (test-path "C:\Program Files (x86)\LANDesk\LDClient\SHH_SRV-STATICROUTE01.ps1") {Write-Output "$env:computername - OK"} else {Write-Output "$env:computername - SCRIPT NOT THERE" }}
$list += $routescript
} 
$list