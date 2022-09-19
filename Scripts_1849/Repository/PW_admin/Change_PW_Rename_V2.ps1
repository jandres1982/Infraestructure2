#Author: Antonio Vicente Vento Maggio
#ICT System Administrator
#
#ConvertFrom-SecureString | Set-Content c:\scriptsencrypted_password1.txt
#
#$credential = Get-Credential
#$password = $credential.Password
 
#$Securing = ConvertTo-SecureString $password -force -asPlainText | Set-Content c:\scriptsencrypted_password1.txt
##$accounts = cmd /c "wmic useraccount get name,sid"
#

#Rename to have the Guess account:




$Guest_account = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'"
$Guest_sid = $Guest_account.sid
$Guest_sid = echo $Guest_sid | Select-String "-501"
$Guest_name = (New-Object System.Security.Principal.SecurityIdentifier($Guest_sid)).Translate([System.Security.Principal.NTAccount]).value
#echo $Guest_name
$Split = $Guest_Name.Split('\')
$Guest = $Split[1]

if($Guest -ne "Guest") {
 
 Write-Host "Guest changed to Schindler Standards"
 Rename-LocalUser -Name $Guest -NewName "Guest"
 Disable-LocalUser -Name "Guest"
}
Disable-LocalUser -Name "Guest"
Write-host "Current Guest with SID 501: $Guest and is set to:"(Get-Localuser -Name guest).enabled
#
#
#
################################################################################################################
#Search for the Built-in -500 account (Enable this account and set no expiration password
#
#
#
$accounts = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'"
$accounts_sid= $accounts.sid
$admin_sid = echo $accounts_sid | Select-String "-500"
#echo $admin_sid
$Admin_account = (New-Object System.Security.Principal.SecurityIdentifier($admin_sid)).Translate([System.Security.Principal.NTAccount]).value
#echo $Admin_account
$Split = $Admin_account.Split('\')
$admin = $Split[1]
Write-host "Current Admin with SID 500: $admin"
Enable-LocalUser -name $admin 
Set-LocalUser -Name $admin -PasswordNeverExpires 1

#
#
#
#
#
#################################################################################################################
#
#Here we define a password on a .txt file encrypted and this file have to be reachable by the script. Ex: C:\temp\password.txt
#If the password is the same for all servers we can skip this line and set the file one time only:
#(get-credential).password | ConvertFrom-SecureString | set-content "C:\temp\password.txt"

#
#
#
$Server_Vault_dmz ="shhwsr0743"
$Server_Vault_glo = "shhwsr1123"
$Server_vault_tst = "tstshhwsr0251"
#$Pw_loc = "\\$Server_Vault\d$\Repository\Working\Antonio\Changing_PW_Rename\Source.txt"
#(get-credential).password | ConvertFrom-SecureString | set-content $Pw_loc

#Global
#if ((Test-Path -Path "\\$Server_Vault_glo\d$"))
#{
$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
$password = Get-Content "c:\temp\Source.txt"| ConvertTo-SecureString -key $key
#$password = Get-Content "C:\Program Files (x86)\LANDesk\LDClient\sdmcache\ldsource$\Packages_V2\Schindler\PW_admin\Source.txt"| ConvertTo-SecureString -key $key


#Dmz
#if ((Test-Path -Path "\\$Server_Vault_tst\d$"))
#{
#$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
#$password = Get-Content "\\$Server_Vault_tst\d$\Repository\Working\Antonio\Changing_PW_Rename\Source.txt" | ConvertTo-SecureString -key $key
#}
#Tst
#if ((Test-Path -Path "\\$Server_Vault_dmz\d$"))
#{
#$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
#$password = Get-Content "\\$Server_Vault_dmz\d$\Repository\Working\Antonio\Changing_PW_Rename\Source.txt" | ConvertTo-SecureString -key $key
#}


#### ---->echo $Password (check password is not visible)

$admin_user = get-localuser -name $admin
$admin_user | Set-LocalUser -Password $Password




#
#
#
#
###############################################################################################################
#Here renames the local account if the name is viewer
#
#
#
#
#
if($admin -eq "viewer") {
 
 Write-Host "Viewer changed to Schindler Standards"
 Rename-LocalUser -Name $admin -NewName "Administrator"


}



######################################### Disabling accounts #############################################

$Swisscom_viewer = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" |Select-Object "name"| Select-String "viewer"

if($Swisscom_viewer -ne $null) {
 
 Write-Host "Viewer changed to Schindler Standards"
 
 Disable-LocalUser -Name "Viewer"


}

$Swisscom_tempadm = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" |Select-Object "name"| Select-String "tempadm"

if($Swisscom_tempadm -ne $null) {
 
 Write-Host "Tempadm changed to Schindler Standards"
 
 Disable-LocalUser -Name "tempadm"


}
########################################## Disabling accounts #############################################

#####End if for reachable servers######



##### End Foreach for checking server list ####3

#
#
#END
##