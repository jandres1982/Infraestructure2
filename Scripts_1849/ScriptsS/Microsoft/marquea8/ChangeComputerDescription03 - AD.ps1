Import-module ActiveDirectory   
Import-CSV "D:\Scripts\Schindler\Microsoft\marquea8\computers.csv" | % {  
$Computer = $_.ComputerName  
$Desc = $_.Description  
Set-ADComputer $Computer -Description $Desc

$fqdn = $Computer + ".global.schindler.com"
Invoke-Command -ComputerName $fqdn -ScriptBlock {$OSWMI = Get-WmiObject -class Win32_OperatingSystem; $OSWMI.Description=$args[0]; $OSWMI.put()} -ArgumentList ($Desc)
}