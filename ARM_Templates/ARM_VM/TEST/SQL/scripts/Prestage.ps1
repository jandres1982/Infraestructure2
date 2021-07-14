# Prestage domain: "global.schindler.com"

# Devops parameters
param([string]$vm,[string]$function,[string]$subs)

# Variables

# Constants
$user = "svcshhldmssosd"
$pw = "76492d1116743f0423413b16050a5345MgB8AFUASQAwAFQASQBlAFkAVQBwAEEAcQA0AFQAVABMAGwAVgBpAE0ASQBRAEEAPQA9AHwAMwBlADYAMgAyAGYAMwAyAGMAZgAwADgAMQA3AGIAZgBhAGEAYwA1ADgAMgA3ADMAOQBhADgAOQAxADUAYwBiADQAMwBhADkAMwBmAGMAMgA1ADcAOQBmAGUAYQAwAGUAYgA1AGUAZQBhADQAZgAwAGIANQBjAGYAOQBmADQAOAA="
$key = (3, 4, 2, 3, 56, 34, 254, 222, 1, 1, 2, 23, 42, 54, 33, 233, 1, 34, 2, 7, 6, 5, 35, 43)

# Main
set-azcontext -subscripction $(subs)
switch ($subs)
{
    "s-sis-eu-prod-01" {$ou = "OU=EU"}
    "s-sis-eu-nonprod-01" {$ou = "OU=EU"}
    "s-sis-ap-prod-01" {$ou = "OU=AP"}
    "s-sis-am-prod-01" {$ou = "OU=AM"}
    "s-sis-am-nonprod-01" {$ou = "OU=AM"}
}
$password = $PW | ConvertTo-SecureString -key $key
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($user, $password)
$vm = $vm.ToUpper()
$kg = $vm.Substring(0,3)
$function = "$kg Windows Server $function"
New-ADComputer -Name $vm -Path "$ou`,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" -PasswordNotRequired $false -Description $function -ErrorAction SilentlyContinue -Credential $cred
write-host "$vm and $function"