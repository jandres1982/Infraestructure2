
$Secret = ConvertTo-SecureString -String 'Password' -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName 'kv-prod-devopsagents-01' -Name 'ITSecret' -SecretValue $Secret


$Secret = ConvertTo-SecureString -String 'Password' -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName 'kv-nonprod-dwpscript-01' -Name 'ITSecret' -SecretValue $Secret