Import-Module vmware.vimautomation.core


$vCenter = Read-Host -Prompt 'Input vCenter Name'
$vmName = Read-Host -Prompt 'Input VM Name'
$requester = Read-Host -Prompt 'Requester'
$request = Read-Host -Prompt 'Request'
$emailAddr = Read-Host -Prompt 'Email'
$snapTime = read-host "Please enter date & time (i.e.: '25 oct 2012 9:00'; date alone set time to 00:00):"
$snapTime = $snapTime -as [datetime]



Connect-VIServer -Server $vCenter


$snapName = "Snap with date $snapTime"

$snapDescription = "Scheduled snapshot requested by $requester for request $request"

$snapMemory = $false

$snapQuiesce = $false


###############

$vm = Get-VM -Name $vmName

 

$si = get-view ServiceInstance

$scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager




$spec = New-Object VMware.Vim.ScheduledTaskSpec

$spec.Name = "Shutdown $($vmName)"

$spec.Description = "Shutdown $($vmName)"

$spec.Enabled = $true

$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler

$spec.Scheduler.runat = $snapTime

 

$spec.Action = New-Object VMware.Vim.MethodAction

$spec.Action.Name = "ShutdownGuest"

$scheduledTaskManager.CreateScheduledTask($vm.ExtensionData.MoRef, $spec)



 

$spec = New-Object VMware.Vim.ScheduledTaskSpec

$spec.Name = "Snapshot",$_.VMname -join ' '

$spec.Description = "Take a snapshot of $($vm.Name)"

$spec.Enabled = $true

$spec.Notification = $emailAddr

 

$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler

$spec.Scheduler.runat = $snapTime.AddMinutes(5)

 

$spec.Action = New-Object VMware.Vim.MethodAction

$spec.Action.Name = "CreateSnapshot_Task"

 

@($snapName,$snapDescription,$snapMemory,$snapQuiesce) | %{

    $arg = New-Object VMware.Vim.MethodActionArgument

    $arg.Value = $_

    $spec.Action.Argument += $arg

}

 

$scheduledTaskManager.CreateObjectScheduledTask($vm.ExtensionData.MoRef, $spec)

$spec = New-Object VMware.Vim.ScheduledTaskSpec

$spec.Name = "Power on $($vmName)"

$spec.Description = "Power on $($vmName)"

$spec.Enabled = $true

$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler

$spec.Scheduler.runat = $snapTime.AddMinutes(8)

 

$spec.Action = New-Object VMware.Vim.MethodAction

$spec.Action.Name = "PowerOnVM_Task"

$scheduledTaskManager.CreateScheduledTask($vm.ExtensionData.MoRef, $spec)

Disconnect-VIServer -confirm:$false