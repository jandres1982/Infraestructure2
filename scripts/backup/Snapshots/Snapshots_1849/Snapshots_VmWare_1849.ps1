param([string]$vm,
[string]$date,
[string]$email,
[string]$Request,
[string]$Type,
[string]$NubesRoAcc,
[string]$NubesRoPw)

$date = $date -as [datetime]

Write-Output "vm: $vm"
Write-Output "date: $date"
Write-Output "email: $email"

$Nubes1 = "vcenterscs"
$Nubes4 = "vcenternubes4"

Import-Module vmware.vimautomation.core


Function Check_VM ($VCenter,$vm)
{
    Connect-VIServer -Server $VCenter -User $NubesRoAcc -Password $NubesRoPw
    $VM_Exist = get-vm -name $VM -ErrorAction SilentlyContinue
    If ($VM_Exist)
       {Return $True}
       else{Return $False}
       Disconnect-VIServer -Server $vcenter -confirm:$false
}


Function Snapshot_VmWare ($vm,$date,$email,$Request,$vcenter)
{
    Connect-VIServer -Server $Vcenter -User $NubesRoAcc -Password $NubesRoPw
    $snapMemory = $true
    $snapQuiesce = $false
    $VmProfile = Get-VM -Name $vm
    $date = $date -as [datetime]
    $snapName = "Snap $vm for the $request"
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

    $scheduledTaskManager.CreateObjectScheduledTask($VmProfile.ExtensionData.MoRef, $spec)
}


Function Power_Off ($vm,$date,$email,$Request,$vcenter)
{
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


#$Check_Nubes4 = Check_VM -VCenter $nubes4 -vm $vm | Select-String "True"
#
#$VCenter = ""
#If ($Check_Nubes1)
#    {
#      if ($Check_Nubes4)
#        {
#        Write-Output "Error $VM is located in both VCenters" > "D:\Snapshots\logs\VmWare_Snap_error_$VM.txt"
#        }else
#            {$VCenter = $Nubes1
#            }
#     }else
#          {
#          if ($Check_Nubes4)
#            {
#            $VCenter = $Nubes4
#            }else
#                {
#                Write-Output "Error $VM is located in both VCenters" > "D:\Snapshots\logs\VmWare_Snap_error_$VM.txt"
#                }
#          }
#


#If ($Check_Nubes1)
#    {$VCenter = $Nubes1
#    $Nubes_Check = Check_VM -VCenter $nubes1 -vm $vm | Select-String "True"
#    Write-Output "$VCenter"
#
#    }else
#        {
#        $VCenter = $Nubes4
#        }
#


#Main

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false
Connect-VIServer -Server $Vcenter -User $NubesRoAcc -Password $NubesRoPw -force
$Check_Nubes1 = Check_VM -VCenter $nubes1 -vm $vm | Select-String "True"

If ($Check_Nubes1)
    {$VCenter = $Nubes1}
        else
            {
            $VCenter = $Nubes4
            write-host "VM located in another VCenter" > "D:\Snapshots\logs\VmWare_Snap_error_$VM.txt"
            }



if ($Type -eq "Offline")
    {
    Power_off -vm $vm -date $date -email $email -Request $Request -vcenter $vcenter
    Snapshot_VmWare -vm $vm -date $date.addminutes(5) -email $email -Request $Request -vcenter $vcenter
    Power_on -vm $vm -date $date.addminutes(8) -email $email -Request $Request -vcenter $vcenter
    }else
        {
        Snapshot_VmWare -vm $vm -date $date -email $email -Request $Request -vcenter $vcenter
        }


#If ($Result_Nubes1)
#    {
#    Write-Output "VM Found we will schedule the snapshot"
#    Snapshot_VmWare -vm $vm -date $date.addminutes(5) -email $email -Request $Request -vcenter $Nubes1
#    }else
#        {Write-Output "VM was not found can't schedule the snapshot"}
#
#
#
Disconnect-VIServer -server $VCenter -confirm:$false