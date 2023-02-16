###Definir Localizacion### 

$location = "northeurope" 

 

###Definir nombre imagen### 

$imageName = "pefesenseImage" 

 

###Definir RG### 

$rgName = "O2-Centralita" 

 

###Definir localizacion imagen### 

$imageConfig = New-AzImageConfig ` 

-Location $location 

 

###Deifinir imagen### 

$imageConfig = Set-AzImageOsDisk ` 

    -Image $imageConfig ` 

    -OsType Linux ` 

    -BlobUri https://migracioncentralita.blob.core.windows.net/vhd-to-azure/pfsense.vhd ` 

    -DiskSizeGB 20 

 

###Crear la imagen### 

New-AzImage ` 

    -ImageName $imageName ` 

    -ResourceGroupName $rgName ` 

    -Image $imageConfig 

 

###Crear la maquina### 

New-AzVm ` 

    -ResourceGroupName $rgName ` 

    -Name "pfsense-centralita" ` 

    -ImageName $imageName ` 

    -Location $location ` 

    -VirtualNetworkName "centralita-vnet" ` 

    -SubnetName "subnet0" ` 

    -SecurityGroupName "O2-Centralita" ` 

    -PublicIpAddressName "ip-wan-pfsense" ` 

    -OpenPorts 22 