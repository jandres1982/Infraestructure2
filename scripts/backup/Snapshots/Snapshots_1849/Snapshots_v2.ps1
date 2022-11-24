param (
[Parameter(Mandatory = $false)]
[string]$vm,
[Parameter(Mandatory = $false)]
[string]$date,
[Parameter(Mandatory = $false)]
[string]$email,
[Parameter(Mandatory = $false)]
[string]$Type,
[Parameter(Mandatory = $false)]
[string]$sub,
[Parameter(Mandatory = $false)]
[string]$requester
)

Import-Module Az.Resources
Import-Module Az.Accounts
Import-Module Az.Compute

Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}
$Current_time = Get-date -Format dd-MM-yyyy-hh-mm
$Logfile = "D:\Snapshots\Result\Snapshot-$vm-$Current_time.txt"
LogWrite "$Current_time :Starting Azure Snapshots Script"



$response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&client_id=2f9eefbb-eb19-486e-9bda-60c11cae3c08&resource=https://management.azure.com/' -Method GET -Headers @{Metadata="true"}
$content = $response.Content | ConvertFrom-Json
$ArmToken = $content.access_token
#LogWrite "$Current_time : $response"

$Login = Connect-AzAccount -AccessToken $ArmToken -Subscription $sub -AccountId $content.client_id
$Logs_login = $Login | Out-String
LogWrite "$Current_time : $Logs_login"
set-azcontext -subscription $sub


Function Azure_Snap
{
$Snap_date = Get-date
$Tags = @{"requester"="$requester"; "date"="$Snap_date"}

Write-Output "Working on $vm"
$snapshotName = "Snapshot_$vm"
$resourceGroup = Get-AzResourceGroup | Where-Object {$_.Tags.infrastructureservice -eq "snapshots"}
$vmDetails = Get-AzVM | Where-Object {$_.Name -eq "$vm"}

##OS Disk Snapshot
$snapshot =  New-AzSnapshotConfig -SourceUri $vmDetails.StorageProfile.OsDisk.ManagedDisk.Id -Location $vmDetails.location -CreateOption copy
$Snap_OS = New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroup.ResourceGroupName
$Logs_OS = $Snap_OS | Out-String
LogWrite "$Current_time : $logs_OS"
New-AzTag -ResourceId $Snap_OS.id -Tag $tags


#New-AzTag -ResourceId $Snap_OS.id -Tag $Tag_Requester,$Tag_Date
#Set-AzResource  -ResourceId  $snap_OS.id -Tag $Tag_Requester -Force
#Set-AzResource  -ResourceId  $snap_OS.id -Tag $Tag_Date -Force


##DATA Disk Snapshots
$Data_disk = $($vmDetails | select-object -Property *).StorageProfile.DataDisks.Name
$i = 0
Foreach ($disk in $Data_disk)
    {
    if ($disk -ne $null)
        {
        $data_disk_id = $(Get-AzResource -Name $disk).ResourceId
        $snapshot =  New-AzSnapshotConfig -SourceUri $data_disk_id -Location $vmDetails.location -CreateOption copy
        $Snap_name = $snapshotName+$i
        $Snap_Disk = New-AzSnapshot -Snapshot $snapshot -SnapshotName $Snap_name -ResourceGroupName $resourceGroup.ResourceGroupName
        $Logs_Disk = $Snap_Disk | Out-String
        LogWrite "$Current_time : $Logs_Disk"
        New-AzTag -ResourceId $Snap_Disk.id -Tag $tags
        $i++
    }else
        {Write-Output "Disk name empty"}
    }
}


Function PowerOff_Azure_VM ([string]$vm)
{
$vmDetails = Get-AzVM | Where-Object {$_.Name -eq "$vm"}
Stop-AzVM -id $vmDetails.Id -force
LogWrite "$Current_time : $vm will be power off"
start-sleep 90
}

Function PowerOn_Azure_VM ([string]$vm)
{
$vmDetails = Get-AzVM | Where-Object {$_.Name -eq "$vm"}
Start-AzVM -id $vmDetails.Id
LogWrite "$Current_time : $vm will be power on"
}



Function Send_Email ([string]$Status)
{
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "$email"

$Subject = "VM -Status $status of $VM"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1

$Body = @"
Snapshots was completed with the following information:
Machine: $vm
Subscription_ID: $sub
eMAIL:$email
"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body
LogWrite "$Current_time : $vm Email will be sent to the user"
}


#Main

If ($type -eq "offline")
    {
    PowerOff_Azure_VM -vm $vm
    Send_Email -Status "PowerOff"
    Azure_Snap
    Send_Email -Status "Snapshot"
    PowerOn_Azure_VM -vm $vm
    Send_Email -Status "PowerOn"
    }else
        {
        Azure_Snap
        Send_Email -Status "Snapshot"
        }

Unregister-ScheduledTask -TaskName "Snapshots_DevOps_$vm" -TaskPath "\Snapshots\" -Confirm:$false