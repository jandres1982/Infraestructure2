param([string]$joinuser,[string]$joinpw)
$password = $joinpw| ConvertTo-SecureString -AsPlainText -Force
$domain = "global.schindler.com"
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuser,$password)
Add-Computer -DomainName $domain -Credential $cred
Restart-Computer -Force