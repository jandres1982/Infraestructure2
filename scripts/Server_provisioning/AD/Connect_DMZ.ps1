$who = whoami
$user = $who.Split("\")[1]
$DMZ_User = $user+"@dmz2.schindler.com"
$password = Read-host 'Please, Include your DMZ PW' -AsSecureString
#$cred = $(get-credential)
#$password = $pass | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($DMZ_User,$password)
Enter-PSSession -ComputerName shhwsr2306.dmz2.schindler.com -Credential $cred