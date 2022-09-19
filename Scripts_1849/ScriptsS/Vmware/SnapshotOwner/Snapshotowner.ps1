[CmdletBinding()]
Param(
   
   [Parameter(Mandatory=$True, Position=1)]
   [string]$vm
)

foreach ($snap in Get-VM $vm | Get-Snapshot)
{$snapevent = Get-VIEvent -Entity $snap.VM -Types Info -Finish $snap.Created -MaxSamples 1 | Where-Object {$_.FullFormattedMessage -imatch 'Task: Create virtual machine snapshot'}
if ($snapevent -ne $null){Write-Host ( "VM: "+ $snap.VM + ". Snapshot '" + $snap + "' created on " + $snap.Created.DateTime + " by " + $snapevent.UserName +".")}
else {Write-Host ("VM: "+ $snap.VM + ". Snapshot '" + $snap + "' created on " + $snap.Created.DateTime + ". This event is not in vCenter events database")}}