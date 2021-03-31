$jd_User = "svcshhldmssosd"
$PW = "76492d1116743f0423413b16050a5345MgB8AFUASQAwAFQASQBlAFkAVQBwAEEAcQA0AFQAVABMAGwAVgBpAE0ASQBRAEEAPQA9AHwAMwBlADYAMgAyAGYAMwAyAGMAZgAwADgAMQA3AGIAZgBhAGEAYwA1ADgAMgA3ADMAOQBhADgAOQAxADUAYwBiADQAMwBhADkAMwBmAGMAMgA1ADcAOQBmAGUAYQAwAGUAYgA1AGUAZQBhADQAZgAwAGIANQBjAGYAOQBmADQAOAA="
$Key = (3, 4, 2, 3, 56, 34, 254, 222, 1, 1, 2, 23, 42, 54, 33, 233, 1, 34, 2, 7, 6, 5, 35, 43)
$password = $PW | ConvertTo-SecureString -key $key
$domain = "global.schindler.com"
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential($jd_User, $password)
Add-Computer -DomainName $domain -Credential $credObject