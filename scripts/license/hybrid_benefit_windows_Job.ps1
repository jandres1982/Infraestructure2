param($subs)
$subs = "s-sis-am-prod-01"
$Servers = Get-Content -Path "Server_List_Hybrid_Benefit_AM.txt"
Select-AzSubscription -Subscription $subs

foreach ($vmName in $Servers)
{
# Choose between Standard_LRS, StandardSSD_LRS and Premium_LRS based on your scenario

if (get-azvm -Name "*$vmName*")
    {
    Start-Job -Name "HybridBenefit_$vmName" -ScriptBlock {
    param($vmName)
    Write-Host "Working in $vmName"
    $vm = get-azvm -Name "*$vmName*"
    $rg = $vm.ResourceGroupName
    $vm.LicenseType = "Windows_Server"
    Update-AzVM -ResourceGroupName $rg -vm $vm
    Write-host "$vmName should have been assigned to Windows Server license type:"
    $vm.LicenseType
    } -ArgumentList $vmName
    }else
    {
    Write-host "$vmName is not found in $sub"
    }
    
}

#$subs = @("s-sis-eu-nonprod-01")
#$subs = @("s-sis-eu-nonprod-01","s-sis-ap-prod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01")
#$subs = @("s-sis-eu-nonprod-01")