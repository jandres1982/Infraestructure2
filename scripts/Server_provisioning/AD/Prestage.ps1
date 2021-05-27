#param([string]$vm,[string]$function)
#$User = "svcshhldmssosd"
#$PW = "76492d1116743f0423413b16050a5345MgB8AFUASQAwAFQASQBlAFkAVQBwAEEAcQA0AFQAVABMAGwAVgBpAE0ASQBRAEEAPQA9AHwAMwBlADYAMgAyAGYAMwAyAGMAZgAwADgAMQA3AGIAZgBhAGEAYwA1ADgAMgA3ADMAOQBhADgAOQAxADUAYwBiADQAMwBhADkAMwBmAGMAMgA1ADcAOQBmAGUAYQAwAGUAYgA1AGUAZQBhADQAZgAwAGIANQBjAGYAOQBmADQAOAA="
#$Key = (3, 4, 2, 3, 56, 34, 254, 222, 1, 1, 2, 23, 42, 54, 33, 233, 1, 34, 2, 7, 6, 5, 35, 43)
#$password = $PW | ConvertTo-SecureString -key $key
#$domain = "global.schindler.com"
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($User, $password)
#New-ADComputer -Name $vm -Path "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" -PasswordNotRequired $false -Description $Function -ErrorAction SilentlyContinue -Credential $cred
#write-host "$vm and $Function"