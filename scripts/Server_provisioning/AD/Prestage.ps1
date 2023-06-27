param([string]$vm,[string]$function,[string]$sub)

$User = "svcshhldmssosd"
$PW = "76492d1116743f0423413b16050a5345MgB8AFUASQAwAFQASQBlAFkAVQBwAEEAcQA0AFQAVABMAGwAVgBpAE0ASQBRAEEAPQA9AHwAMwBlADYAMgAyAGYAMwAyAGMAZgAwADgAMQA3AGIAZgBhAGEAYwA1ADgAMgA3ADMAOQBhADgAOQAxADUAYwBiADQAMwBhADkAMwBmAGMAMgA1ADcAOQBmAGUAYQAwAGUAYgA1AGUAZQBhADQAZgAwAGIANQBjAGYAOQBmADQAOAA="
$Key = (3, 4, 2, 3, 56, 34, 254, 222, 1, 1, 2, 23, 42, 54, 33, 233, 1, 34, 2, 7, 6, 5, 35, 43)
$password = $PW | ConvertTo-SecureString -key $key
$domain = "global.schindler.com"
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($User, $password)
$vm = $vm.ToUpper()
$KG = $vm.Substring(0,3)
$function = "$KG Windows Server $function"
$path = ""

switch ($sub)
{
"s-sis-eu-prod-01" {$path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-eu-nonprod-01" {$path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-ap-prod-01" {$path = "OU=AP,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-am-prod-01" {$path = "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-am-nonprod-01" {$path = "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-ch-nonprod-01" {$path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-ch-prod-01" {$path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
}

New-ADComputer -Name $vm -Path $path -PasswordNotRequired $false -Description $Function -ErrorAction SilentlyContinue -Credential $cred

write-host "$vm and $Function"

###EU
#If ($sub -eq "s-sis-eu-prod-01" -or $sub -eq "s-sis-eu-nonprod-01")
#{
#$PW = "76492d1116743f0423413b16050a5345MgB8AFUASQAwAFQASQBlAFkAVQBwAEEAcQA0AFQAVABMAGwAVgBpAE0ASQBRAEEAPQA9AHwAMwBlADYAMgAyAGYAMwAyAGMAZgAwADgAMQA3AGIAZgBhAGEAYwA1ADgAMgA3ADMAOQBhADgAOQAxADUAYwBiADQAMwBhADkAMwBmAGMAMgA1ADcAOQBmAGUAYQAwAGUAYgA1AGUAZQBhADQAZgAwAGIANQBjAGYAOQBmADQAOAA="
#$Key = (3, 4, 2, 3, 56, 34, 254, 222, 1, 1, 2, 23, 42, 54, 33, 233, 1, 34, 2, 7, 6, 5, 35, 43)
#$password = $PW | ConvertTo-SecureString -key $key
#$domain = "global.schindler.com"
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($User, $password)
#$vm = $vm.ToUpper()
#$KG = $vm.Substring(0,3)
#$function = "$KG Windows Server $function"
#New-ADComputer -Name $vm -Path "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" -PasswordNotRequired $false -Description $Function -ErrorAction SilentlyContinue -Credential $cred
#write-host "$vm and $Function"
#}
###AP
#
#$PW = "76492d1116743f0423413b16050a5345MgB8AFUASQAwAFQASQBlAFkAVQBwAEEAcQA0AFQAVABMAGwAVgBpAE0ASQBRAEEAPQA9AHwAMwBlADYAMgAyAGYAMwAyAGMAZgAwADgAMQA3AGIAZgBhAGEAYwA1ADgAMgA3ADMAOQBhADgAOQAxADUAYwBiADQAMwBhADkAMwBmAGMAMgA1ADcAOQBmAGUAYQAwAGUAYgA1AGUAZQBhADQAZgAwAGIANQBjAGYAOQBmADQAOAA="
#$Key = (3, 4, 2, 3, 56, 34, 254, 222, 1, 1, 2, 23, 42, 54, 33, 233, 1, 34, 2, 7, 6, 5, 35, 43)
#$password = $PW | ConvertTo-SecureString -key $key
#$domain = "global.schindler.com"
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($User, $password)
#$vm = $vm.ToUpper()
#$KG = $vm.Substring(0,3)
#$function = "$KG Windows Server $function"
#New-ADComputer -Name $vm -Path "OU=AP,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" -PasswordNotRequired $false -Description $Function -ErrorAction SilentlyContinue -Credential $cred
#write-host "$vm and $Function"
#
###AM
#
#$PW = "76492d1116743f0423413b16050a5345MgB8AFUASQAwAFQASQBlAFkAVQBwAEEAcQA0AFQAVABMAGwAVgBpAE0ASQBRAEEAPQA9AHwAMwBlADYAMgAyAGYAMwAyAGMAZgAwADgAMQA3AGIAZgBhAGEAYwA1ADgAMgA3ADMAOQBhADgAOQAxADUAYwBiADQAMwBhADkAMwBmAGMAMgA1ADcAOQBmAGUAYQAwAGUAYgA1AGUAZQBhADQAZgAwAGIANQBjAGYAOQBmADQAOAA="
#$Key = (3, 4, 2, 3, 56, 34, 254, 222, 1, 1, 2, 23, 42, 54, 33, 233, 1, 34, 2, 7, 6, 5, 35, 43)
#$password = $PW | ConvertTo-SecureString -key $key
#$domain = "global.schindler.com"
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($User, $password)
#$vm = $vm.ToUpper()
#$KG = $vm.Substring(0,3)
#$function = "$KG Windows Server $function"
#New-ADComputer -Name $vm -Path "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" -PasswordNotRequired $false -Description $Function -ErrorAction SilentlyContinue -Credential $cred
#write-host "$vm and $Function"