



#For SQL RSV no policy are required
#RG need to be created before appliying this script ex: rg-cis-prod-backup-01
$location = "East US 2"
#Check if this RG exist:
$rg = "rg-cis-prod-backup-01"
#Please change the "prod-use2" to the right naming for the subscription:
$sub = "s-sis-am-prod-01"
$vault_zone = "rsv-prod-use2-zrsbackupsql-01"
$pe_zone = "pe-sql-prod-04" #check the right number behind the variable in private endpoint in Azure
$vnetname = "vnet-prod-use2-01"
$vnet_rg = "rg-cis-prod-network-01"

New-AzRecoveryServicesVault -Name $vault_zone -ResourceGroupName $rg -Location $location
az backup vault backup-properties set --backup-storage-redundancy ZoneRedundant --name $vault_zone --resource-group $rg --subscription $sub

$vault = Get-AzRecoveryServicesVault -ResourceGroupName $rg -Name $vault_zone
$privateEndpointConnection = New-AzPrivateLinkServiceConnection `
        -Name $pe_zone `
        -PrivateLinkServiceId $vault.ID `
        -GroupId "AzureBackup"

$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $vnet_rg
$subnet = $vnet | Select -ExpandProperty subnets | Where-Object {$_.Name -eq 'sub-backend-iaas-01'}

$privateEndpoint = New-AzPrivateEndpoint `
        -ResourceGroupName $vmResourceGroupName `
        -Name $privateEndpointName `
        -Location $location `
        -Subnet $subnet `
        -PrivateLinkServiceConnection $privateEndpointConnection `
        -Force



New-AzRecoveryServicesVault -Name "rsv-prod-use2-lrsbackupsql-01" -ResourceGroupName $rg -Location $location
az backup vault backup-properties set --backup-storage-redundancy LocallyRedundant --name "rsv-prod-use2-lrsbackupsql-01" --resource-group $rg --subscription $sub

New-AzRecoveryServicesVault -Name "rsv-prod-use2-grsbackupsql-01" -ResourceGroupName $rg -Location $location
az backup vault backup-properties set --backup-storage-redundancy GeoRedundant --name "rsv-prod-use2-grsbackupsql-01" --resource-group $rg --subscription $sub


### Private End Point for SQL Recovery Service Vault

$vault = Get-AzRecoveryServicesVault -ResourceGroupName $rg -Name $vaultName
  
$privateEndpointConnection = New-AzPrivateLinkServiceConnection `
        -Name $privateEndpointConnectionName `
        -PrivateLinkServiceId $vault.ID `
        -GroupId "AzureBackup"  

$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $VMResourceGroupName
$subnet = $vnet | Select -ExpandProperty subnets | Where-Object {$_.Name -eq '<subnetName>'}


$privateEndpoint = New-AzPrivateEndpoint `
        -ResourceGroupName $vmResourceGroupName `
        -Name $privateEndpointName `
        -Location $location `
        -Subnet $subnet `
        -PrivateLinkServiceConnection $privateEndpointConnection `
        -Force








#For VM RSV Backup policy need to be created
New-AzRecoveryServicesVault -Name "rsv-prod-use2-lrsbackup-01" -ResourceGroupName $rg -Location $location
New-AzRecoveryServicesVault -Name "rsv-prod-use2-grsbackup-01" -ResourceGroupName $rg -Location $location
