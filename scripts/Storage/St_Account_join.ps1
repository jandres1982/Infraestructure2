#St Account less than 15 characters.
#No object need to be previosly created in AD.
$Storage_account = "sttestadjoin01"
$Domain = "global.schindler.com"
$OU = "OU=zzz,OU=servers,OU=NBI12,DC=global,DC=schindler,DC=com"
$ResourceGroupName = "rg-cis-nonprod-storage-01"
Join-AzStorageAccountForAuth -ResourceGroupName $ResourceGroupName -StorageAccountName $Storage_account -DomainAccountType ComputerAccount -OrganizationalUnitDistinguishedName $OU