
#################################################################### EU non prod
Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_nonprod.txt

$VM_EU_NonProd = Get-Content "servers_list_eu_nonprod.txt"
foreach ($vm in $VM_EU_NonProd)
{
#$rg = (get-azvm -Name $vm).ResourceGroupName
#write-host "$vm and $rg"

#az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "hostname"
$vm = "shhwsr2022"
Invoke-Command -ComputerName $vm -ScriptBlock {
    function Remove_proxy
    {
    param($ProxyDomainName="")
    
    # First we get the Health Service configuration object.  We need to determine if we
    # have the right update rollup with the API we need.  If not, no need to run the rest of the script.
    $healthServiceSettings = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    
    $proxyMethod = $healthServiceSettings | Get-Member -Name 'SetProxyInfo'
    
    if (!$proxyMethod)
    {
        Write-Output 'Health Service proxy API not present, will not update settings.'
        return
    }
    
    Write-Output "Clearing proxy settings."
    $healthServiceSettings.SetProxyInfo('', '', '')
    
    
    }
    Remove_proxy

}

}
