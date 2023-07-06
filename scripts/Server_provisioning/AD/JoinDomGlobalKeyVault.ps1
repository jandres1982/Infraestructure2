param([string]$vm,[string]$joinuser,$joinpw)
$domain = "global.schindler.com"
$joinpw = $joinpw | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuser, $joinpw)
Add-Computer -DomainName $domain -Credential $cred
Start-Sleep 5
Restart-Computer -Force