param([string]$vm,
[string]$date,
[string]$email,
[string]$Request,
[string]$Type,
[string]$JsgRoAcc,
[string]$JsgRoPw)

$date = $date -as [datetime]

Write-Output "vm: $vm"
Write-Output "date: $date"
Write-Output "email: $email"

$JsgVcenter = "srtxap0002.global.schindler.com"

Import-Module vmware.vimautomation.core


Function Check_VM ($Vcenter,$vm)
{
    Connect-VIServer -Server $Vcenter -User $JsgRoAcc -Password $JsgRoPw -force
    $VM_Exist = get-vm -name $VM -ErrorAction SilentlyContinue
    If ($VM_Exist)
       {Return $True}
       else{Return $False}
       Disconnect-VIServer -Server $Vcenter -confirm:$false
}


Function Snapshot_VmWare ($vm,$date,$email,$Request,$vcenter)
{
    Connect-VIServer -Server $Vcenter -User $JsgRoAcc -Password $JsgRoPw -force
    $snapMemory = $true
    $snapQuiesce = $false
    $VmProfile = Get-VM -Name $vm
    $date = $date -as [datetime]
    $snapName = "Snap $vm for $request"
    $Time = [datetime]$date
    $FromTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Romance Standard Time")
    $date = ([System.TimeZoneInfo]::ConvertTimeToUtc($Time, $FromTimeZone)) 
    $snapDescription = "Scheduled snapshot requested by $email for request $request"
    $si = get-view ServiceInstance
    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager
    $spec = New-Object VMware.Vim.ScheduledTaskSpec
    $spec.Name = $snapName
    $spec.Description = $snapDescription
    $spec.Enabled = $true
    $spec.Notification = $email
    $spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
    $spec.Scheduler.runat = $date
    $spec.Action = New-Object VMware.Vim.MethodAction
    $spec.Action.Name = "CreateSnapshot_Task"
    @($snapName,$snapDescription,$snapMemory,$snapQuiesce) | %{
        $arg = New-Object VMware.Vim.MethodActionArgument
        $arg.Value = $_
        $spec.Action.Argument += $arg}
    #Return $snapName
    $scheduledTaskManager.CreateObjectScheduledTask($VmProfile.ExtensionData.MoRef, $spec)
}


Function Power_Off ($vm,$date,$email,$Request,$vcenter)
{
    Connect-VIServer -Server $Vcenter -User $JsgRoAcc -Password $JsgRoPw -force
    $VmProfile = Get-VM -Name $vm
    $date = $date -as [datetime]
    $snapName = "PowerOff Server $vm for the $request"
    $date = [datetime]$date
    $FromTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Romance Standard Time")
    $date = ([System.TimeZoneInfo]::ConvertTimeToUtc($date, $FromTimeZone)) 
    $snapDescription = "Power Off Server $email for request $request"
    $si = get-view ServiceInstance
    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager
    $spec = New-Object VMware.Vim.ScheduledTaskSpec
    $spec.Name = "Shutdown $vm for the $request"
    $spec.Description = "Shutdown $vm for the $request"
    $spec.Enabled = $true
    $spec.Notification = $email
    $spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
    $spec.Scheduler.runat = $date
    $spec.Action = New-Object VMware.Vim.MethodAction
    $spec.Action.Name = "ShutdownGuest"
    $scheduledTaskManager.CreateScheduledTask($VmProfile.ExtensionData.MoRef, $spec)
}


Function Power_On ($vm,$date,$email,$Request,$vcenter)
{
    Connect-VIServer -Server $Vcenter -User $JsgRoAcc -Password $JsgRoPw -force
    $VmProfile = Get-VM -Name $vm
    $date = $date -as [datetime]
    $snapName = "PowerOn Server $vm for the $request"
    $date = [datetime]$date
    $FromTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Romance Standard Time")
    $date = ([System.TimeZoneInfo]::ConvertTimeToUtc($date, $FromTimeZone)) 
    $snapDescription = "Power On Server $email for request $request"
    $si = get-view ServiceInstance
    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager
    $spec = New-Object VMware.Vim.ScheduledTaskSpec
    $spec.Name = "PowerOn $vm for the $request"
    $spec.Description = "PowerOn $vm for $request"
    $spec.Enabled = $true
    $spec.Notification = $email
    $spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
    $spec.Scheduler.runat = $date
    $spec.Action = New-Object VMware.Vim.MethodAction
    $spec.Action.Name = "PowerOnVM_Task"
    $scheduledTaskManager.CreateScheduledTask($VmProfile.ExtensionData.MoRef, $spec)
}

Function Remove_ScheduleTask ($Vcenter,$snapname)
{
Connect-VIServer -Server $Vcenter -User $JsgRoAcc -Password $JsgRoPw -force
$si = Get-View ServiceInstance
$scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager
if ($scheduledTaskManager.ScheduledTask)
    {
    $t = Get-View -Id $scheduledTaskManager.ScheduledTask | where{$_.Info.Name -eq $snapname}
    $t.RemoveScheduledTask()}
    else{
    Write-host "Nothing to do, there is not task created" -ForegroundColor Yellow}
}


Function Remove_Snapshot ($Vcenter,$vm,$snapName)
{
Connect-VIServer -Server $Vcenter -User $JsgRoAcc -Password $JsgRoPw -force
$VmProfile = Get-VM -Name $vm
$Snap = Get-Snapshot -vm $vm -Name $snapName -ErrorAction SilentlyContinue
    if ($snap)
    {Remove-Snapshot $Snap -Confirm:$false -ErrorAction SilentlyContinue
    }
    else
        {Write-Output "No Snap found for $VM"}
}


#Main

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false
#Connect-VIServer -Server $Vcenter -User $NubesRoAcc -Password $NubesRoPw -force
$Check_jsgvm = Check_VM -VCenter $JsgVcenter -vm $vm | Select-String "True"
$snapName = "Snap $vm for $request"

If ($Check_jsgvm)
    {
    ####
    $Current_time = Get-date -Format dd-MM-yyyy-hh-mm
    Write-Output $Current_time >> "D:\Snapshots\logs\jsgxap0001\Snap_$VM.txt"
    Remove_ScheduleTask -Vcenter $JsgVcenter -snapname $snapName
    $RemoveSnap = Remove_Snapshot -vm $vm -Vcenter $JsgVcenter -snapName $snapName
    Write-Output $RemoveSnap[1] >> "D:\Snapshots\logs\jsgxap0001\Snap_$VM.txt"
    
    ####
    $Current_time = Get-date -Format dd-MM-yyyy-hh-mm
    Write-Output $Current_time >> "D:\Snapshots\logs\jsgxap0001\Snap_$VM.txt"
    $StartSnapSchedule = Snapshot_VmWare -vm $vm -date $date -email $email -Request $Request -vcenter $JsgVcenter
    Write-Output $StartSnapSchedule[1] >> "D:\Snapshots\logs\jsgxap0001\Snap_$VM.txt"
    }
        else
            {
            $Current_time = Get-date -Format dd-MM-yyyy-hh-mm
            Write-Output $Current_time >> "D:\Snapshots\logs\jsgxap0001\Snap_$VM.txt"
            write-host "$vm cannot be located" > "D:\Snapshots\logs\jsgxap0001\Snap_$VM.txt"
            }




Disconnect-VIServer -server $JsgVcenter -confirm:$false

