console
cmd
ch -si 1
powershell.exe

#cmd join domain
#netdom.exe join shhwsr2315 /domain:global /UserD:global\admventoa1 /PasswordD:

#Powershell rejoin
az account set --subscription "505ead1a-5a5f-4363-9b72-83eb2234a43d"
Select-AzSubscription -Subscription "s-sis-eu-prod-01"
az vm run-command invoke --command-id RunPowerShellScript --name "shhwsr2228" -g "RG-SHH-PROD-JAVAAPPLICATION-01" --scripts "
$pw = 
$user = "admventoa1"
$domain = "global.schindler.com"
$password = $PW | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($user,$password)
test-computersecurechannel -repair -credential $cred
"