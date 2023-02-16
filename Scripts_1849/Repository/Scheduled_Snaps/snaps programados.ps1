Import-Module vmware.vimautomation.core


$vCenter = Read-Host -Prompt 'Input vCenter Name'
$vmName = Read-Host -Prompt 'Input VM Name'
$requester = Read-Host -Prompt 'Requester'
$request = Read-Host -Prompt 'Request'
$emailAddr = Read-Host -Prompt 'Email'
$snapTime = read-host "Please enter date & time (for example: 25 april 2021 9:00):"
$snapTime = $snapTime -as [datetime]



Connect-VIServer -Server $vCenter


$snapName = "Snap with date $snapTime"

$snapDescription = "Scheduled snapshot requested by $requester for request $request"

$snapMemory = $true

$snapQuiesce = $false



$vm = Get-VM -Name $vmName

 

$si = get-view ServiceInstance

$scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager

 

$spec = New-Object VMware.Vim.ScheduledTaskSpec

$spec.Name = "Take a snapshot of $($vm.Name) with date $snaptime"

$spec.Description = "Take a snapshot of $($vm.Name)"

$spec.Enabled = $true

$spec.Notification = $emailAddr

 

$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler

$spec.Scheduler.runat = $snapTime

 

$spec.Action = New-Object VMware.Vim.MethodAction

$spec.Action.Name = "CreateSnapshot_Task"

 

@($snapName,$snapDescription,$snapMemory,$snapQuiesce) | %{

    $arg = New-Object VMware.Vim.MethodActionArgument

    $arg.Value = $_

    $spec.Action.Argument += $arg

}

 

$scheduledTaskManager.CreateObjectScheduledTask($vm.ExtensionData.MoRef, $spec)

Disconnect-VIServer -confirm:$false