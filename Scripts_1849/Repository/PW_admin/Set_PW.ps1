#Set the Password
#$credential = Get-Credential
$Server_Vault_glo = "shhwsr1123"
$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
(get-credential).password | ConvertFrom-SecureString -Key $key | set-content "\\$Server_Vault_glo\D$\LDSource\Packages_V2\Schindler\PW_admin\Source.txt"


