#===================================================================================#
#                                                                                   #
# Nubes_Pre-migration-Check.ps1                                                     #
# Powershell script to check VMs to be migrated in next hour (Pre-Migration checks) #
# The script queries the cloudinator database. A list of VMs that will be migrated  #
# next hour, will be generated and checked in vCenterSHH for certain conditions     #
# an email is sent for every server.                                                #
#                                                                                   #
# Author: Michael Barmettler                                                        #
# Creation Date: 12.07.2016                                                         #
# Modified Date: 12.07.2016                                                         #
# Version: 01.00.01                                                                 #
#                                                                                   #
# Example: powershell.exe .\Nubes_Pre-migration-Check.ps1                           #
#                                                                                   #
#===================================================================================#


$PSEmailServer = "smtp.eu.schindler.com"
$From = "$env:computername@ch.schindler.com"
$To =  "scc.support@ch.schindler.com"


#######################################################
# Query the Cloudinator Database to get all VMs with migration date
Import-Module SQLPS

$ServerInstance = "10.10.100.112"
$DB = "MigDB"
$SQLUser = "sa-db-schindlerexport"  #Read only permission
$SQLpw = "3d81e118-6859-4d91-8948-f36710de0d91"

$SQLquery =@" 
 
select server_name, CONVERT(varchar,lswave_date,104) as lswave_day, CONVERT(varchar,lswave_date,108) as lswave_time, lswave_site
 from dbo.rhserver as rhs INNER JOIN server as srv
 ON rhs.rhserver_id = srv.server_id
 INNER JOIN lswave as lsw
 ON rhserver_lswave = lsw.lswave_id
 
"@ 
 
$serverlist = invoke-sqlcmd -query $SQLquery -serverinstance $ServerInstance -database $DB -Username $SQLUser -Password $SQLpw

########################################################
# Filter for only VMs migrated next hour

$today = (Get-Date).AddHours(+1).ToString('dd.MM.yyyy')
$nexthour = (Get-Date).AddHours(+1).ToString('HH')

$vms =@{}
$vms = $serverlist | Where-Object {$_.lswave_day -like "$today" -and $_.lswave_time -like "$($nexthour):*"}


#########################################################


#Query vCenter for every VM
if ($vms){

Add-PSSnapin -Name VMware*
$VIServer = "vcentershh.global.schindler.com"
Connect-VIServer -Server $VIServer

foreach ($vm in $vms.server_name) {

$Severity = "OK"

$gvm = get-vm $vm

$body00 = "Nubes-Pre-Migration Check: $vm"
$body01 = "=================================================="

######## Snapshot
$Snapshot = ($gvm | Get-Snapshot).Name
if ($Snapshot){
$body10 = "WARNING - Snapshot: $Snapshot"
$Severity = "WARNING"
}
else {
$body10 = "OK - No Snapshot"}

######## ISO
$ISO = ($gvm | select-object @{Label="ISO"; Expression = {($_ | Get-CDDrive).ISOPath}}).ISO
if ($ISO){
$body20 = "WARNING - ISO: $ISO"
$Severity = "WARNING"
}
else {
$body20 = "OK - No ISO"}

######## VMTools
$VMtools = ($gvm).extensiondata.Guest.ToolsStatus
if ($VMtools -like "toolsOk" -or $VMtools -like "toolsOld") {
$body30 = "OK - VMware Tools Status: $VMtools "
}
else {
$body30 = "WARNING - Tools: $VMtools"
$Severity = "WARNING"

}

######## SRM Replication
$vmv = Get-View $gvm
$dest = $vmv.config.ExtraConfig | select | where {$_.key -eq “hbr_filter.destination”}
If (($dest) -and ($dest.Value)) {
$body35 = "WARNING -  VM is replicated with SRM"
$Severity = "WARNING"
}
else {
$body35 = "OK - No SRM Replication"
}


######## General Information Section

$Datastores = ($gvm | get-datastore).name
$VMHost = ($gvm | get-vmhost).name
$Cluster = ($gvm | Get-cluster).name
$GuestDisks = ($gvm | get-vmguest).disks
$GuestDiskSpaceFreeGB = ($GuestDisks | Measure-Object -Property FreeSpaceGB -Sum).sum
$GuestDiskSpaceTotalGB = ($GuestDisks | Measure-Object -Property CapacityGB -Sum).sum
$GuestDiskSpaceUsedGB = [Math]::Round($GuestDiskSpaceTotalGB - $GuestDiskSpaceFreeGB,2)
$UsedSpaceGBVM = [Math]::Round($gvm.usedspaceGB,2)

$body40 = ""
$body41 = "General Info:"
$body42 = "=================================================="
$body43 = "Source Datastores: $Datastores"
$body44 = "Source Host: $VMHost"
$body45 = "Source Cluster: $Cluster"
$body46 = "Used Space GB (VMware): $UsedSpaceGBVM"
$body47 = "Used Space GB (Guest): $GuestDiskSpaceUsedGB"
$body48 = "Migration Time: $($vm.lswave_time)"


#Send Mail

$Subject = "$vm - Pre-Migration Check - $Severity"
$Body = "$body00`n$body01`n$body10`n$body20`n$body30`n$body35`n$body40`n$body41`n$body42`n$body43`n$body44`n$body45`n$body46`n$body47"

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
}
}