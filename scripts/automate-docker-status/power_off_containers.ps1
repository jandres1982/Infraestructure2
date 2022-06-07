$containers=Get-AzContainerGroup | where {$_.Tags.Keys -contains "auto-power-off" -and $_.Tags.Values -contains "yes"}
ForEach ($container in $containers)
{
    $name = $container.Name
    $rg = $container.ResourceGroupName
    Stop-AzContainerGroup -Name $name -ResourceGroupName $rg
    "$name is stopped"
}