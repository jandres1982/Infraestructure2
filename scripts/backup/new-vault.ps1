### Variables ###
$vaultname="rsv-nonprod-use2-lrsbackupsql-01"
$rg="rg-cis-nonprod-backup-01"
$location="eastus2"
$sub="s-sis-am-nonprod-01"
### Select the subscription ###
Set-AzContext -Subscription $sub
### Creating recovery service vault ###
New-AzRecoveryServicesVault -Name $vaultname -ResourceGroupName $rg -Location $location
### Store vault properties in a new variable ##
$vault=Get-AzRecoveryServicesVault -Name $vaultname
### Configuring vault redundancy ###
Set-AzRecoveryServicesBackupProperty -Vault $vault -BackupStorageRedundancy LocallyRedundant
### Enable identity for the vault ###
Update-AzRecoveryServicesVault -ResourceGroupName $vault.ResourceGroupName -Name $vault.Name -IdentityType SystemAssigned
start-sleep -seconds 30
### Store managed identity id ###
$managedidentity=Get-AzADServicePrincipal -DisplayName $vaultname
### Grant Contributor Role over RG for Vault Identity ###
New-AzRoleAssignment -ObjectId $managedidentity.id -RoleDefinitionName "Contributor" -ResourceGroupName $rg
#New-AzRoleAssignment -ObjectId $managedidentity.id -RoleDefinitionName "Contributor" -ResourceName Devices-Engineering-ProjectRND -ResourceType Microsoft.Network/virtualNetworks/subnets -ParentResource virtualNetworks/VNET-EASTUS-01 -ResourceGroupName Network