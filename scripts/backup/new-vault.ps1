### Variables ###
$vaultname="rsv-nonprod-chno-lrsbackup-01"
$rg="rg-cis-nonprod-backup-01"
$location="switzerlandnorth"
$sub="s-sis-ch-nonprod-01"
$pe="pe-backup-nonprod-0003"
$subnet="sub-middleware-01"
$redundancy="LocallyRedundant"
### Select the subscription ###
Set-AzContext -Subscription $sub
### Creating recovery service vault ###
New-AzRecoveryServicesVault -Name $vaultname -ResourceGroupName $rg -Location $location
### Store vault properties in a new variable ##
$vault=Get-AzRecoveryServicesVault -Name $vaultname
### Configuring vault redundancy ###
Set-AzRecoveryServicesBackupProperty -Vault $vault -BackupStorageRedundancy $redundancy
### Enable identity for the vault ###
Update-AzRecoveryServicesVault -ResourceGroupName $vault.ResourceGroupName -Name $vault.Name -IdentityType SystemAssigned
start-sleep -seconds 60
### Store managed identity id ###
$managedidentity=Get-AzADServicePrincipal -DisplayName $vaultname
### Grant Contributor Role over RG for Vault Identity ###
New-AzRoleAssignment -ObjectId $managedidentity.id -RoleDefinitionName "Contributor" -ResourceGroupName $rg
### Get vnet and subnet info ###
$vnet=Get-AzVirtualNetwork
$subnet=$vnet.Subnets | Where-Object {$_.Name -eq "$subnet"}
### Grant Contributor Role over vNet for Vault Identity ###
New-AzRoleAssignment -ObjectId $managedidentity.id -RoleDefinitionName "Contributor" -ResourceGroupName $vnet.ResourceGroupName -ResourceType Microsoft.Network/virtualNetworks -ResourceName $vnet.Name
echo "Recovery Service Vault $vaultname has been created"
### Create Private Link Service ###
$plsConnection= New-AzPrivateLinkServiceConnection -Name $vaultname -GroupId "AzureBackup" -PrivateLinkServiceId $vault.id
### Create Private Endpoint ###
New-AzPrivateEndpoint -Name $pe -ResourceGroup $vault.ResourceGroupName -Location $location -PrivateLinkServiceConnection $plsConnection -Subnet $subnet
echo "Private Endpoint $pe has been created"
