$sub = "s-sis-eu-nonprod-01"
$vm = "zzzwsr0012"
$ConversionTable = Import-Csv -LiteralPath ".\SizeConversionTable.csv" -Delimiter ";"
Select-AzSubscription -Subscription $sub
$vm = Get-AzVM -Name $vm
$Rg = $vm.ResourceGroupName
$CurrentSize = $vm.HardwareProfile.VmSize
$Result = $ConversionTable | Where-Object { $_.OldSize -match $CurrentSize }

if ($Result) {
    $vm.HardwareProfile.VmSize = $Result.NewSize
    $UpdateVm = Update-AzVM -VM $vm -ResourceGroupName $rg}
else {Write-Host "Nothing to do" -ForegroundColor Yellow}