$VMs = Get-Azvm | where {$_.Tags.Keys -contains "auto-power-off" -and $_.Tags.Values -contains "yes"}
ForEach ($VM in $VMs)
{
    $VMStatus2 = Get-Azvm -Name $VM.Name -ResourceGroupName $VM.resourcegroupname -Status

    $VMN = $VM.Name
    $VMRG = $VM.resourcegroupname
    $VMPS = $VMStatus2.Statuses[1].DisplayStatus
        if ($VMPS = "VM Running")
        {
            Stop-Azvm -Name $VMN -ResourceGroupName $VMRG -Force
            "$VMN is Shutdown and Deallocated"
        }
}