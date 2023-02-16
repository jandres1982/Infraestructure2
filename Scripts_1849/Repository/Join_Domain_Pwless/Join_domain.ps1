#pregeneratePW with set pw script:
$PW = "76492d1116743f0423413b16050a5345MgB8ADQAYwBKAFUAdQBZAFoAMQA1AGIAaQBlAHcAYwB0AEsAMAAzAGUAYwBRAEEAPQA9AHwAYwBiAGUAMwAwADAAYwBjADYAMwAzADcAMwAwADIAYgAxADQAZAA1AGEAOAA0AGIAMgBmADYANwA1AGIAOQA1AGUANwA5AGMAMgA4ADIAOAAwADEAYQBlAGUANQA1AGUANwA5AGEAZAA4ADEAZQA0AGUANwBmADgAMgA0AGEAZAA="
$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,158,1,34,2,7,6,5,35,43)
$password = $PW | ConvertTo-SecureString -key $key
$username = "svcshhldmssosd"
$domain = "global.schindler.com"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName $domain -Credential $credential