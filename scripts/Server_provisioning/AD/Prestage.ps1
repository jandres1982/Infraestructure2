$vm = $args[0]
$Function = $args[1]
#New-ADComputer -Name $vm -Path "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" -PasswordNotRequired $false -Description $Function -ErrorAction SilentlyContinue

write-host "$vm and $Function"