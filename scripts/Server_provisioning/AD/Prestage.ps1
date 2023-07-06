param([string]$vm,[string]$function,[string]$sub,[string]$joinuser,$joinpw)

$password = $joinpw | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($joinuser, $password)
$vm = $vm.ToUpper()
$KG = $vm.Substring(0,3)
$function = "$KG Windows Server $function"
$path = ""

switch ($sub)
{
"s-sis-eu-prod-01" {$path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-eu-nonprod-01" {$path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-ap-prod-01" {$path = "OU=AP,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-am-prod-01" {$path = "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-am-nonprod-01" {$path = "OU=AM,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-ch-nonprod-01" {$path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
"s-sis-ch-prod-01" {$path = "OU=EU,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com"}
}

New-ADComputer -Name $vm -Path $path -PasswordNotRequired $false -Description $Function -ErrorAction SilentlyContinue -Credential $cred

write-host "$vm and $Function"