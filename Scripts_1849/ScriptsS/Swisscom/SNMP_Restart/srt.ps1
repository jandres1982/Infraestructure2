$srvName = "SNMP"		
$servicePrior = Get-Service $srvName		
"$srvName is now " + $servicePrior.status		
Set-Service $srvName -startuptype automatic		
Restart-Service $srvName		
$serviceAfter = Get-Service $srvName		
"$srvName is now " + $serviceAfter.status