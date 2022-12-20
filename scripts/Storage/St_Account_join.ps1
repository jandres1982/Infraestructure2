Import-Module -Name AzFilesHybrid
$Storage_account = "stqualsqlfileshare01"
$Domain = "global.schindler.com"
$OU = "OU=zzz,OU=servers,OU=NBI12,DC=global,DC=schindler,DC=com"
$ResourceGroupName = "rg-shh-qual-rmp-01"
#You will need to install powershell module AzFilesHybrid
Join-AzStorageAccountForAuth -ResourceGroupName $ResourceGroupName -StorageAccountName $Storage_account -DomainAccountType ComputerAccount -OrganizationalUnitDistinguishedName $OU