#$subs = @("s-sis-ch-prod-01","s-sis-ch-nonprod-01","s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-ap-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01")
$subs = Get-AzSubscription | Where-Object { $_.Name -match "s-sis-[aec][upmh]*" }
foreach ($sub in $subs) {
    Write-Output "Working on $Sub"
    Select-AzSubscription -Subscription $sub

    $servers = Get-AzVM | Where-Object { $_.Name -like "*wsr*" }

    foreach ($vmName in $Servers.name) {

        if (get-azvm -Name "*$vmName*") {
            Write-Host "Working in $vmName"
            $vm = get-azvm -Name "*$vmName*"
            $rg = $vm.ResourceGroupName
            If ($vm.LicenseType -eq "Windows_Server") {
                Write-Host "Nothing to Do" 
            }
            else { 
                $vm.LicenseType = "Windows_Server"
                Update-AzVM -ResourceGroupName $rg -vm $vm
                Write-host "$vmName should have been assigned to Windows Server license type:"
                $vm.LicenseType
            }
        }
        else {
            Write-host "$vmName is not found in $sub"
        }
    }
}