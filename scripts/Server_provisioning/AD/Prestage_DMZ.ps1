param([string]$vm,[string]$function,[string]$joinuserdmz,$joinpwdmz1)

write-host "$joinuserdmz"
write-host "$joinpwdmz1"

$joinpwdmz1 = $joinpwdmz1 | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuserdmz, $joinpwdmz)
$vm = $vm.ToUpper()
$KG = $vm.Substring(0,3)
$function = "$KG Windows Server $function"
#Invoke-Command -ComputerName "shhwsr2306.dmz2.schindler.com" -Credential $cred -ScriptBlock {param($vm,$function,$cred) New-ADComputer -Name $vm -Path "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -PasswordNotRequired $false -Description $function -credential $cred} -ArgumentList $vm,$function,$cred
$DmzScriptingServer = "shhwsr2306.dmz2.schindler.com"
$parameters = @{
    ComputerName = $DmzScriptingServer
    Credential = $cred
    ScriptBlock = {param($vm,$function,$cred) New-ADComputer -Name $vm -Path "OU=000,OU=Servers,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -PasswordNotRequired $false -Description $function -credential $cred}
    ArgumentList =  $vm,$function,$cred
}
Invoke-Command @parameters