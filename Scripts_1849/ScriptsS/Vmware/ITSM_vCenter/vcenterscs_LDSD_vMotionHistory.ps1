﻿
$Credentials = Get-Credential -Message "vCenterscs Credentials" -UserName "SA-PF01-vCSchiRO@itoper.local"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Connect-VIServer -Server "vCenterscs.global.schindler.com" -Credential $Credentials -ErrorAction Stop

$si = Get-View ServiceInstance
$setting = Get-View $si.Content.Setting
$vcid = $setting.QueryOptions("instance.id") | Select -ExpandProperty Value


function Get-VIEventPlus {
<#
PS> Get-VIEventPlus -Entity $vm -Recurse:$true
#>
param(
[VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl[]]$Entity,
[string[]]$EventType,
[DateTime]$Start,
[DateTime]$Finish = (Get-Date),
[switch]$Recurse,
[string[]]$User,
[Switch]$System,
[string]$ScheduledTask,
[switch]$FullMessage = $false
)
process {
$eventnumber = 100
$events = @()
$eventMgr = Get-View EventManager
$eventFilter = New-Object VMware.Vim.EventFilterSpec
$eventFilter.disableFullMessage = ! $FullMessage
$eventFilter.entity = New-Object VMware.Vim.EventFilterSpecByEntity
$eventFilter.entity.recursion = &{if($Recurse){"all"}else{"self"}}
$eventFilter.eventTypeId = $EventType
if($Start -or $Finish){
$eventFilter.time = New-Object VMware.Vim.EventFilterSpecByTime
if($Start){
$eventFilter.time.beginTime = $Start
}
if($Finish){
$eventFilter.time.endTime = $Finish
}
}
if($User -or $System){
$eventFilter.UserName = New-Object VMware.Vim.EventFilterSpecByUsername
if($User){
$eventFilter.UserName.userList = $User
}
if($System){
$eventFilter.UserName.systemUser = $System
}
}
if($ScheduledTask){
$si = Get-View ServiceInstance
$schTskMgr = Get-View $si.Content.ScheduledTaskManager
$eventFilter.ScheduledTask = Get-View $schTskMgr.ScheduledTask |
where {$_.Info.Name -match $ScheduledTask} |
Select -First 1 |
Select -ExpandProperty MoRef
}
if(!$Entity){
$Entity = @(Get-Folder -Name Datacenters)
}
$entity | %{
$eventFilter.entity.entity = $_.ExtensionData.MoRef
$eventCollector = Get-View ($eventMgr.CreateCollectorForEvents($eventFilter))
$eventsBuffer = $eventCollector.ReadNextEvents($eventnumber)
while($eventsBuffer){
$events += $eventsBuffer
$eventsBuffer = $eventCollector.ReadNextEvents($eventnumber)
}
$eventCollector.DestroyCollector()
}
$events
}
}
function Get-MotionHistory {
<#   
PS> Get-MotionHistory -Entity $vm -Days 10
#>
param(
[CmdletBinding(DefaultParameterSetName="Days")]
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
[VMware.VimAutomation.ViCore.Impl.V1.Inventory.InventoryItemImpl[]]$Entity,
[Parameter(ParameterSetName='Days')]
[int]$Days = 1,
[Parameter(ParameterSetName='Hours')]
[int]$Hours,
[Parameter(ParameterSetName='Minutes')]
[int]$Minutes,
[switch]$Recurse = $false,
[switch]$Sort = $true
)
begin{
$history = @()
switch($psCmdlet.ParameterSetName){
'Days' {
$start = (Get-Date).AddDays(- $Days)
}
'Hours' {
$start = (Get-Date).AddHours(- $Hours)
}
'Minutes' {
$start = (Get-Date).AddMinutes(- $Minutes)
}
}
$eventTypes = "DrsVmMigratedEvent","VmMigratedEvent"
}
process{
$history += Get-VIEventPlus -Entity $entity -Start $start -EventType $eventTypes -Recurse:$Recurse |
Select CreatedTime,
@{N="Type";E={
if($_.SourceDatastore.Name -eq $_.Ds.Name){"vMotion"}else{"svMotion"}}},
@{N="UserName";E={if($_.UserName){$_.UserName}else{"System"}}},
@{N="VM";E={$_.VM.Name}},
@{N="SrcVMHost";E={$_.SourceHost.Name.Split('.')[0]}},
@{N="TgtVMHost";E={if($_.Host.Name -ne $_.SourceHost.Name){$_.Host.Name.Split('.')[0]}}},
@{N="SrcDatastore";E={$_.SourceDatastore.Name}},
@{N="TgtDatastore";E={if($_.Ds.Name -ne $_.SourceDatastore.Name){$_.Ds.Name}}}
}
end{
if($Sort){
$history | Sort-Object -Property CreatedTime
}
else{
$history
}
}
}

#Disconnect vCenter
Disconnect-viserver -server $vcname -confirm:$false