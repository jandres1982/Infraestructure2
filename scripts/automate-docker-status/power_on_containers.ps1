$containers=Get-AzContainerGroup | where {$_.Tag.Keys -contains "auto-power-off" -and $_.Tag.Values -contains "yes"}
ForEach ($container in $containers)
{
    $name = $container.Name
    $rg = $container.ResourceGroupName
    Start-AzContainerGroup -Name $name -ResourceGroupName $rg
    "$name is running"
}


