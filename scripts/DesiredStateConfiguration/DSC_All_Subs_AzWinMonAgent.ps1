#################################################################### 

$subs = @("s-sis-eu-nonprod-01")
#, "s-sis-eu-prod-01", "s-sis-am-prod-01", "s-sis-am-nonprod-01", "s-sis-ap-prod-01", "s-sis-ch-prod-01", "s-sis-ch-nonprod-01")

###################################################################

foreach ($sub in $subs) {


        Select-AzSubscription -Subscription "$sub"
        #Set-AzContext -Subscription "$sub"
        #$(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_$sub.txt
        $(Get-AzVM | Select -Property Name, @{Name = 'OSType'; Expression = { $_.StorageProfile.OSDisk.OSType } } | where-object { $_.OsType -eq "Windows" }).name > .\servers_list_$sub.txt
        $Servers = Get-Content "servers_list_$sub.txt"
        $Servers = $Servers | Sort-Object

        [int]$num_T = $Servers.Count #Per_variables
        [int]$num_R = $num_T #Per_variables
        [int]$Per = $null #Per_variables
        [int]$Per_1 = $null #Per_variables

        foreach ($vm in $Servers) {
                Write-host "We are in VM $vm"
                $VmProfile = get-azvm -Name $vm
                $rg = $VmProfile.ResourceGroupName
                $location = $VmProfile.Location

                ##################### Checking VM's Status #################################
                #$VmStatus = get-azvm -Name $vm -ResourceGroupName $rg -Status
                $Status = $vmStatus.statuses[1].DisplayStatus

                If ($Status -eq "VM running") {

                        ######################### Check MicrosoftMonitoringAgent extension is enable in the VM 
                        $extension = $VmStatus.Extensions.name
                        $AzWinMonAgent = $extension | Select-String "AzureMonitorWindowsAgent"
                        if ($AzWinMonAgent) {
                                Write-host "$AzWinMonAgent extension already exist"   
                        }
                        else {
                                Set-AzVMExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $rg -VMName $vm -Location $location -TypeHandlerVersion "1.14" -EnableAutomaticUpgrade $true
                        }

                        Switch ($extension) {
                                MicrosoftMonitoringAgent { Remove-AzVMExtension -Name MicrosoftMonitoringAgent -ResourceGroupName $rg  -VMName $vm -Confirm:$false -force }
                                Microsoft.Insights.LogAnalyticsAgent { Remove-AzVMExtension -Name Microsoft.Insights.LogAnalyticsAgent -ResourceGroupName $rg  -VMName $vm -Confirm:$false -force }
                        }
                }
                else {
                        $Status = "OFF, can't remove or install extension"
                }

                ##########################  Check $per START ###############################

                #write-host "Remaining Servers $num_R"
                $num_R = $num_R - 1
                $Per = 100 - (($num_R * 100) / $num_T)


                if ($per -eq $per_1) {
                        #write-host "is equal"
                        Write-host "$num_R | $vm | $rg | $Status"
                }
                else {
                        Write-host "$num_R | $vm | $rg | $Status | $per%"
                        #Show Percentage
                }
                $per_1 = $per

                ##########################  Check $per END #################################
        }
}