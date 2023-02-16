param (
[Parameter(Mandatory = $false)]
[string]$sub,
[Parameter(Mandatory = $false)]
[string]$vm
)
##Set Subscription##
set-azcontext -subscription $sub
$vmDetails = Get-AzVM | Where-Object {$_.Name -eq "$vm"}

##Stop VM##
Start-AzVM -Name $vmDetails.Name -ResourceGroupName $vmDetails.ResourceGroupName
