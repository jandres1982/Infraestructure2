$vmname = "shhwsr2999"
cd "C:\Users\ventoa1\OneDrive - Schindler\Azure_Devops\Infraestructure\Terraform\azure\vm"
$var = Get-Content .\variables_vm.tf
$var.replace("zzzwsr0203",$vmname) | out-file var_test1.tf