$containers=Get-AzContainerGroup | where {$_.Tags.Keys -contains "auto-power-off" -and $_.Tags.Values -contains "yes"}
ForEach ($container in $containers)
{
    $name = $container.Name
    $rg = $container.ResourceGroupName
    $VMPS = $VMStatus2.Statuses[0].DisplayStatus
    Stop-AzContainerGroup -Name test-cg -ResourceGroupName test-rg
    "$name is stopped"
}