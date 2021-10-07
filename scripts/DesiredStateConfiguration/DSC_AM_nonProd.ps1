
#################################################################### Am non prod
Select-AzSubscription -Subscription "s-sis-am-nonprod-01"
$VM_AM_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_nonprod.txt

$VM_AM_NonProd = Get-Content "servers_list_am_nonprod.txt"
foreach ($vm in $VM_AM_NonProd)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "

#Post_migration_task_Microsoft_Monitoring_Agent.


function Remove_proxy
{
param($ProxyDomainName="webgateway-eu.schindler.com:3128")
$healthServiceSettings = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$proxyMethod = $healthServiceSettings | Get-Member -Name 'SetProxyInfo'

if (!$proxyMethod)
{
    Write-Output 'Health Service proxy API not present, will not update settings.'
    return
}
Write-Output "Clearing proxy settings."
$healthServiceSettings.SetProxyInfo('', '', '')
#Write-Output "Setting proxy to $ProxyDomainName"
$healthServiceSettings.SetProxyInfo("", "","")
}


#main

Remove_proxy



"
}
