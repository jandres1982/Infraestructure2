Import-Module -Name AzFilesHybrid
set-azcontext -subscription $(sub)
$Domain = "global.schindler.com"
$OU = "OU=zzz,OU=servers,OU=NBI12,DC=global,DC=schindler,DC=com"
#You will need to install powershell module AzFilesHybrid
Join-AzStorageAccountForAuth -ResourceGroupName $(rg) -StorageAccountName $(stname) -DomainAccountType ComputerAccount -OrganizationalUnitDistinguishedName $OU