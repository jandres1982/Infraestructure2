
$rg =$(rg)
$vm = $(vm)
$nic = $vm+"_01"
$subnetName = $(subnetName)
$size = $(size)
$Os_disK_type =$(Os_disK_type)


New-AzResourceGroupDeployment `
-ResourceGroupName $rg `
-TemplateParameterFile "Parameters.json" `
-TemplateFile "Template_2019.json" `
-virtualMachineName $vm `
-virtualMachineComputerName $vm `
-networkInterfaceName  $nic `
-subnetName $subnetName `
-virtualMachineSize $size `
-osDiskType $Os_disK_type