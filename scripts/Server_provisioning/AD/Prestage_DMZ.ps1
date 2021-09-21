param([string]$vm,[string]$function)
#$User = "svcshhldmssosd"
#$PW = "76492d1116743f0423413b16050a5345MgB8AHoATgBxAEgAYgBHAFkAbQAvAEQARgBrACsAMABvAGQAUgBPAGgAOABtAHcAPQA9AHwAZAA0AGEANAAxAGIAOQBhADAAOQA5ADIAZQA5ADMAZgAyADUAYgA0ADgANwAxAGUANwA0ADcANAA1AGEAZABkADkAZgA1ADAANgAwAGUAMgBjAGQAZgBiADkAMwAzAGIAMgAzADYAOQAzADkANQA4ADIAYwA1AGQAOAA2ADAAYgA="
#$Key = (5,4,2,4,56,34,254,222,6,5,2,23,42,54,33,233,1,35,2,7,6,4,35,43)
#$password = $PW | ConvertTo-SecureString -key $key
#$domain = "dmz2.schindler.com"
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($User, $password)
$vm = $vm.ToUpper()
$KG = $vm.Substring(0,3)
$function = "$KG Windows Server $function"
New-ADComputer -Name $vm -Path "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -PasswordNotRequired $false -Description $function
write-host "$vm and $Function"

##script to prestage and group

$Admin_Head = $KG+"_RES_SY_"
$Admin_Tail="_ADMIN"
$Admin_Group = "$Admin_Head$Server_UP$Admin_Tail"
New-ADGroup -Name $Admin_Group -GroupCategory Security -GroupScope Universal -DisplayName "$vm Administrators" -Path "OU=RES,OU=Groups,OU=Admin_Global,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -Description "$vm Administrators"