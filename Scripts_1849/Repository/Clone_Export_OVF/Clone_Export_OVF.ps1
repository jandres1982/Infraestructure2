Import-Module VMware.VimAutomation.Core

$vCenter = Read-Host -Prompt 'Input vCenter Name'
Connect-VIServer -Server $vCenter
$vm = Read-Host -Prompt 'Input vm Name that you want to clone'
$vmhost = get-vm $vm | Get-VMHost
$datastore = get-vm  $vm| Get-Datastore | select -first 1
$clone = "-clone"
$dstvm = "$vm$clone"

New-VM -VM $vm -Name $dstvm -VMHost $vmhost -Datastore $datastore -RunAsync -ErrorAction Stop

Export-VApp -VM $dstvm -Format Ova -Destination "\\milwsr0129\exports" -force -ErrorAction Stop


Disconnect-VIServer -Confirm:$false
