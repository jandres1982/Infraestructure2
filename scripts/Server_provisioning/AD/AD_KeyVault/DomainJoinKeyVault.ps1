$password = $(joinpw)| ConvertTo-SecureString -AsPlainText -Force
$domain = "global.schindler.com"
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($(joinuser),$password)
write-output "$(joinuser)"
write-output "$(joinpw)"
Add-Computer -DomainName $domain -Credential $cred