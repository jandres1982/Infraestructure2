#Set the Password
#$credential = Get-Credential
#$Server_Vault_glo = "shhwsr1123"
#When prompt please include the pw of the service account to join the domain, this will generate an encryted file with PW to be revealed with the Key only
$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,158,1,34,2,7,6,5,35,43)
(get-credential).password | ConvertFrom-SecureString -Key $key | set-content "D:\Repository\Working\Antonio\Join_Domain_Pwless\JPEncrypted.txt"

