Import-Module vmware.vimautomation.core


$vCenter = Read-Host -Prompt 'Input vCenter Name'


$snapMemory = $false

$snapQuiesce = $false

$fileName = 'D:\Repository\Scripts\Scheduled_Snaps\snap.csv'

Connect-VIServer -Server $vCenter

 

Import-Csv -Path $fileName -UseCulture | %{

    

    $vm = Get-VM -Name $_.VMName
    $requester = $_.Requester
    $request = $_.Request
    $emailAddr = $_.Email
    $snapDescription = "Scheduled snapshot requested by $requester for request $request"
    $snaptime = $_.Date
    $snapTime = $snapTime -as [datetime]
    $snapName = "Snap $vm at date $snapTime"
    

    $si = get-view ServiceInstance

    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager

    
$spec = New-Object VMware.Vim.ScheduledTaskSpec

$spec.Name = "Shutdown $($vm) at $snapTime"

$spec.Description = "Shutdown $($vm) at $snapTime"

$spec.Enabled = $true

$spec.Notification = $emailAddr

$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler

$spec.Scheduler.runat = $snapTime

 

$spec.Action = New-Object VMware.Vim.MethodAction

$spec.Action.Name = "ShutdownGuest"

$scheduledTaskManager.CreateScheduledTask($vm.ExtensionData.MoRef, $spec)



 

$spec = New-Object VMware.Vim.ScheduledTaskSpec

$spec.Name = $snapName

$spec.Description = $snapDescription

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

$spec.Name = "Power on $($vm) at $snapTime"

$spec.Description = "Power on $($vm) at $snapTime"

$spec.Enabled = $true

$spec.Notification = $emailAddr

$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler

$spec.Scheduler.runat = $snapTime.AddMinutes(8)

 

$spec.Action = New-Object VMware.Vim.MethodAction

$spec.Action.Name = "PowerOnVM_Task"

$scheduledTaskManager.CreateScheduledTask($vm.ExtensionData.MoRef, $spec)


}

Disconnect-VIServer -confirm:$false