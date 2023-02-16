### Variables ###
$sub="s-sis-eu-nonprod-01"
$storagename="stnonprodtestscript01"
$rg="rg-cis-test-server-01"
$pe="pe-stnonprodtestscript01"
$location="northeurope"

### Select Subscription ###
set-azcontext -subscription $sub

### Create Storage Account ###
New-AzStorageAccount -ResourceGroupName $rg -AccountName $storagename -Location $location -SkuName Standard_LRS -AllowBlobPublicAccess $false -PublicNetworkAccess Disabled

echo "Storage Account $storagename has been created"
### Get vnet and subnet info ###
$vnet=Get-AzVirtualNetwork
$subnet=$vnet.Subnets | Where-Object {$_.Name -match '^*generic*'}

### Get info about storage account ###
$storage=Get-AzStorageAccount -Name $storagename -ResourceGroupName $rg

### Create Private Link Service ###
$plsConnection= New-AzPrivateLinkServiceConnection -Name $storagename -GroupId "Blob" -PrivateLinkServiceId $storage.id

### Create Private Endpoint ###
New-AzPrivateEndpoint -Name $pe -ResourceGroup $storage.ResourceGroupName -Location $location -PrivateLinkServiceConnection $plsConnection -Subnet $subnet
echo "Private Endpoint $pe has been created"
