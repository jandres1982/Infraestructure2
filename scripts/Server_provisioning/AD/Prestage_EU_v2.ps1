param([string]$vm,[string]$function,[string]$joinuser,$joinpw)
$vm = $vm.ToUpper()
$KG = $vm.Substring(0,3)
$function = "$KG Windows Server $function"

#$pw = $(Get-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'JoinPw').SecretValue
#$pw = $joinpw.SecretValue

#$user = $(Get-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'JoinUser' -AsPlainText)
#$user = 
echo "this is join user: $joinuser"
echo "this is join pw: $joinpw"
$joinpw = $joinpw | ConvertTo-SecureString
echo "this is join pw converted to secure string: $joinpw"
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuser,$joinpw)

New-ADComputer -Name $vm -Path "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" -PasswordNotRequired $false -Description $Function -Credential $cred
write-host "$vm and $Function"

#$pw = Get-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'JoinPwTstglobal'
#$user = Get-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'JoinUserTstglobal'