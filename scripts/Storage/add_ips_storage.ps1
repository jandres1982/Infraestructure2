
###Set subscription
set-azcontext -subscription "$(sub)"
###Set the keyvault
$st=Get-AzStorageAccount | where {$_.StorageAccountName -eq "$(storageaccount)"}

$ips= Get-Content "publicip.txt"
foreach ($ip in $ips)
{
    Add-AzStorageAccountNetworkRule -ResourcegroupName $st.ResourcegroupName -Name $st.StorageAccountName -IpAddressRange "$ip" 
}
