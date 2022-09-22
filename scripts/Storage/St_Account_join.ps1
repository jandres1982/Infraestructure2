#St Account less than 15 characters.
#No object need to be previosly created in AD.
Import-Module -Name AzFilesHybrid
$Storage_account = "sttestsqlfileshare01"
$Domain = "global.schindler.com"
$OU = "OU=zzz,OU=servers,OU=NBI12,DC=global,DC=schindler,DC=com"
$ResourceGroupName = "rg-shh-test-sqlfileshare-01"
#You will need to install powershell module AzFilesHybrid
Join-AzStorageAccountForAuth -ResourceGroupName $ResourceGroupName -StorageAccountName $Storage_account -DomainAccountType ComputerAccount -OrganizationalUnitDistinguishedName $OU

#azcopy copy "C:\local\path" "https://account.blob.core.windows.net/mycontainer1/?sv=2018-03-28&ss=bjqt&srt=sco&sp=rwddgcup&se=2019-05-01T05:01:17Z&st=2019-04-30T21:01:17Z&spr=https&sig=MGCXiyEzbtttkr3ewJIh2AR8KrghSy1DGM9ovN734bQF4%3D" --recursive=true –preserve-smb-permissions=true