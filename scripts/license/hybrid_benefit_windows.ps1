$vm = Get-AzVM -ResourceGroup "rg-name" -Name "vm-name"$vm.LicenseType = "Windows_Server"
Update-AzVM -ResourceGroupName rg-name -VM $vm