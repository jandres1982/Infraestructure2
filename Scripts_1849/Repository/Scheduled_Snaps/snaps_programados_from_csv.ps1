Clear-Host


cmd.exe /c "C:\Program Files\Notepad++\notepad++.exe" "D:\Repository\Working\Antonio\Scheduled_Snaps\snap.csv"



##################################################################################################### SNAPSHOT SWISSCOM ONLINE ####################################################################

Function Snapshot_from_Csv_Swisscom
{


Import-Module vmware.vimautomation.core


#$vCenter = Read-Host -Prompt 'Input vCenter Name'

#$snapTime = Get-Date "2019/12/31 23:00"

#$snapName = "Snap with date $snapTime"
#VCenterSwisscom = vcenterscs
#VCenterKG = shhwsr1032
#Credential: itoper.local\Swisscom_Ext_User

$snapMemory = $true

$snapQuiesce = $false


$fileName = 'D:\Repository\Working\Antonio\Scheduled_Snaps\snap.csv'

Connect-VIServer -Server $vCenter -Credential $Swisscom_Cred

 

Import-Csv -Path $fileName -UseCulture | %{

    

    $vm = Get-VM -Name $_.VMName
    $requester = $_.Requester
    $request = $_.Request
    $emailAddr = $_.Email
    $snaptime = $_.Date
    $snapTime = $snapTime -as [datetime]
    $snapName = "Snap $vm at date $snapTime"
    $Time = [datetime]$snaptime
    $FromTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Romance Standard Time")
    $snapTime = ([System.TimeZoneInfo]::ConvertTimeToUtc($Time, $FromTimeZone)) 
    #$snapTime = $snaptime ####################################################### check this value (Winter -1, summer -2)
    #$snapTime = $snaptime.addhours(-1) ####################################################### check this value (Winter -1, summer -2)
    $snapDescription = "Scheduled snapshot requested by $requester for request $request"
    
   
    $si = get-view ServiceInstance

    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager

    

    $spec = New-Object VMware.Vim.ScheduledTaskSpec

    $spec.Name = $snapName

    $spec.Description = $snapDescription

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

}





Disconnect-VIServer -confirm:$false


}


##################################################################################################### SNAPSHOT RIMS ONLINE ####################################################################

Function Snapshot_from_Csv_RIMS_KG
{


Import-Module vmware.vimautomation.core


#$vCenter = Read-Host -Prompt 'Input vCenter Name'

#$snapTime = Get-Date "2019/12/31 23:00"

#$snapName = "Snap with date $snapTime"
#VCenterSwisscom = vcenterscs
#VCenterKG = shhwsr1032
#Credential: itoper.local\Swisscom_Ext_User

$snapMemory = $true

$snapQuiesce = $false


$fileName = 'D:\Repository\Working\Antonio\Scheduled_Snaps\snap.csv'

Connect-VIServer -Server $vCenter -Credential $Global_Cred

 

Import-Csv -Path $fileName -UseCulture | %{

    

    $vm = Get-VM -Name $_.VMName
    $requester = $_.Requester
    $request = $_.Request
    $emailAddr = $_.Email
    $snaptime = $_.Date
    $snapTime = $snapTime -as [datetime]
    $snapName = "Snap $vm at date $snapTime"
    $snapDescription = "Scheduled snapshot requested by $requester for request $request"
    
    

    $si = get-view ServiceInstance

    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager

    

    $spec = New-Object VMware.Vim.ScheduledTaskSpec

    $spec.Name = $snapName

    $spec.Description = $snapDescription

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

}





Disconnect-VIServer -confirm:$false


}

##################################################################################################### SNAPSHOT Swisscom OFFLINE ####################################################################

Function Snapshot_from_Csv_Swisscom_offline

{



Import-Module vmware.vimautomation.core


#$vCenter = Read-Host -Prompt 'Input vCenter Name'


$snapMemory = $false

$snapQuiesce = $false

$fileName = "D:\Repository\Working\Antonio\Scheduled_Snaps\snap.csv"

Connect-VIServer -Server $vCenter -Credential $Swisscom_Cred


Import-Csv -Path $fileName -UseCulture | %{

    

    $vm = Get-VM -Name $_.VMName
    $requester = $_.Requester
    $request = $_.Request
    $emailAddr = $_.Email
    $snapDescription = "Scheduled snapshot requested by $requester for request $request"
    $snaptime = $_.Date
    $timetoshow = $_.Date
    $snapTime = $snapTime -as [datetime]
    $snapName = "Snap $vm at date $snapTime"
    $Time = [datetime]$snaptime
    $FromTimeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById("Romance Standard Time")
    $snapTime = ([System.TimeZoneInfo]::ConvertTimeToUtc($Time, $FromTimeZone))
    

    $si = get-view ServiceInstance

    $scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager

    
$spec = New-Object VMware.Vim.ScheduledTaskSpec


##


$spec.Name = "Shutdown $($vm) at $timetoshow"

$spec.Description = "Shutdown $($vm) at $timetoshow"

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

$spec.Name = "Power on $($vm) at $timetoshow"

$spec.Description = "Power on $($vm) at $timetoshow"

$spec.Enabled = $true

$spec.Notification = $emailAddr

$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler

$spec.Scheduler.runat = $snapTime.AddMinutes(8)

 

$spec.Action = New-Object VMware.Vim.MethodAction

$spec.Action.Name = "PowerOnVM_Task"

$scheduledTaskManager.CreateScheduledTask($vm.ExtensionData.MoRef, $spec)


}

Disconnect-VIServer -confirm:$false




}


Function Snapshot_from_Csv_RIMS_KG_offline

{



Import-Module vmware.vimautomation.core


#$vCenter = Read-Host -Prompt 'Input vCenter Name'


$snapMemory = $false

$snapQuiesce = $false

$fileName = "D:\Repository\Working\Antonio\Scheduled_Snaps\snap.csv"

Connect-VIServer -Server $vCenter -Credential $Global_Cred


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




}


$ON_OFF = Read-Host "Please select online or offline depending on the request"

If ($ON_OFF -eq "online" -or $ON_OFF -eq "ONLINE")
{

$vCenter_Read = Read-host "Please choose the VCenter were the VM is located (Select: Swisscom, KG or RIMS)"

if ($vCenter_read -eq "swisscom" -or $vCenter_read -eq "SWISSCOM" -or $vCenter_read -eq "Swisscom" )
{
$vCenter = "vcenterscs"
$Swisscom_User = Read-host "Please include your Swisscom EXT user"
$Swisscom_Cred = Get-Credential itoper.local\$Swisscom_User
Snapshot_from_Csv_Swisscom

}
Else
   {
   if ($vCenter_read -eq "KG" -or $vCenter_read -eq "kg" -or $vCenter_read -eq "kgs" -or $vCenter_read -eq "KGS")
   {
    $vCenter = "shhwsr1032"
    $Global_Cred = Get-Credential (whoami)
    Snapshot_from_Csv_RIMS_KG
   }else
       {
       if ($vCenter_read -eq "RIMS" -or $vCenter_read -eq "rims")
       {
       $vCenter = "srtxap0002"
       $Global_Cred = Get-Credential (whoami)

       Snapshot_from_Csv_RIMS_KG
       }
       else
          {Write-host "VCenter not ok, please check" -ForegroundColor red -BackgroundColor white
          $VCenter = "NULL"
          }
}
}



Write-host "You are using VCenter $Vcenter" -ForegroundColor Green

}
   else
     {
      If ($ON_OFF -eq "offline" -or $ON_OFF -eq "OFFLINE")
      {

       $vCenter_Read = Read-host "Please choose the VCenter were the VM is located (Select: Swisscom, KG or RIMS)"

       if ($vCenter_read -eq "swisscom" -or $vCenter_read -eq "SWISSCOM" -or $vCenter_read -eq "Swisscom" )
       {
       $vCenter = "vcenterscs"
       $Swisscom_User = Read-host "Please include your Swisscom EXT user"
       $Swisscom_Cred = Get-Credential itoper.local\$Swisscom_User
       Snapshot_from_Csv_Swisscom_offline
       
       }
       Else
          {
          if ($vCenter_read -eq "KG" -or $vCenter_read -eq "kg" -or $vCenter_read -eq "kgs" -or $vCenter_read -eq "KGS")
          {
           $vCenter = "shhwsr1032"
           $Global_Cred = Get-Credential (whoami)
           Snapshot_from_Csv_RIMS_KG_offline
          }else
              {
              if ($vCenter_read -eq "RIMS" -or $vCenter_read -eq "rims")
              {
              $vCenter = "srtxap0002"
              $Global_Cred = Get-Credential (whoami)
       
              Snapshot_from_Csv_RIMS_KG_offline
              }
       else
          {Write-host "VCenter not ok, please check" -ForegroundColor red -BackgroundColor white
          $VCenter = "NULL"
          }
              }
       }
       
       Write-host "You are using VCenter $Vcenter" -ForegroundColor Green

       }
       else
       {
       Write-host "$ON_OFF not available"
       }
       
       
       
       }
       






