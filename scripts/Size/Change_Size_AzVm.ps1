select-azSubscription s-sis-eu-nonprod-01
#Get-AzResource -ResourceGroupName rg-cis-test-server-01
$vm = Get-AzVM -ResourceGroupName 'rg-cis-test-server-01' -VMName 'zzzwsr0010'
$Current_Size= $vm.HardwareProfile.VmSize
Write-Output "$Current_Size"
$vm.HardwareProfile.VmSize = 'Standard_D4ds_v5'
Update-AzVM -VM $vm -ResourceGroupName 'rg-cis-test-server-01'