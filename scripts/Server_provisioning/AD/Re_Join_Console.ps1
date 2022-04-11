console
cmd
ch -si 1
powershell.exe

#cmd join domain
#netdom.exe join shhwsr2315 /domain:global /UserD:global\admventoa1 /PasswordD:

#Powershell rejoin
$PW = ""
$password = $PW | ConvertTo-SecureString -AsPlainText -Force
$domain = "global.schindler.com"
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ("",$password)
test-computersecurechannel -repair -credential $cred