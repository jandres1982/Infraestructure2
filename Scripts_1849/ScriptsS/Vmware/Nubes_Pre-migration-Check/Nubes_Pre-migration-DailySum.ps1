#===================================================================================#
#                                                                                   #
# Nubes_Pre-migration-Check.ps1                                                     #
# Powershell script to check VMs to be migrated in two day (Pre-Migration checks)   #
# The script queries the cloudinator database. A list of VMs that will be migrated  #
# next day, will be generated and checked in vCenterSHH for certain conditions      #
# an email is sent.                                                                 #
#                                                                                   #
# Author: Michael Barmettler                                                        #
# Creation Date: 12.07.2016                                                         #
# Modified Date: 27.07.2016                                                         #
# Version: 01.05.00                                                                 #
#                                                                                   #
# Example: powershell.exe .\Nubes_Pre-migration-Check.ps1                           #
#                                                                                   #
#===================================================================================#


$PSEmailServer = "smtp.eu.schindler.com"
$From = "$env:computername@ch.schindler.com"
$To = "michael.barmettler@ch.schindler.com" ,"scc.support@ch.schindler.com", "inf.dc.se@ch.schindler.com"


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
# Filter for only VMs migrated Today

#Get day of the week...
$dayofweek = (get-date).dayofweek.value__

$in1days = (Get-Date).AddDays(+1).ToString('dd.MM.yyyy')
$in2days = (Get-Date).AddDays(+2).ToString('dd.MM.yyyy')
$in3days = (Get-Date).AddDays(+3).ToString('dd.MM.yyyy')
$in4days = (Get-Date).AddDays(+4).ToString('dd.MM.yyyy')

$vms =@{}

#If today is Thursday, take all VMs that will be migrated Saturday, Sunday and Monday
if ($dayofweek -like "4"){
$vms = $serverlist | Where-Object {$_.lswave_day -like "$in2days" -or $_.lswave_day -like "$in3days" -or $_.lswave_day -like "$in4days"}
$Subject = "Pre-Migration Summary for: $in2days ,$in3days, $in4days"
$body00 = "The following VMs will be migrated Saturday, Sunday and Monday:"
}

#If today is Friday, take all VMs that will be migrated Tuesday
elseif ($dayofweek -like "5") {
$vms = $serverlist | Where-Object {$_.lswave_day -like "$in4days"}
$Subject = "Pre-Migration Summary for: $in4days"
$body00 = "The following VMs will be migrated next Tuesday:"
}

#All other days
else {
$vms = $serverlist | Where-Object {$_.lswave_day -like "$in2days"}
$Subject = "Pre-Migration Summary for: $in2days"
$body00 = "The following VMs will be migrated in two days:"
}



#########################################################
#Query vCenter for every VM
if ($vms){

Add-PSSnapin -Name VMware*
$VIServer = "vcentershh.global.schindler.com"
Connect-VIServer -Server $VIServer


[System.Collections.ArrayList]$report = $Null
$report = @()

foreach ($vm in $vms.server_name) {

$gvm = get-vm $vm

######## Snapshot
$Snapshot = ($gvm | Get-Snapshot).Name
if ($Snapshot){
$body10 = "$vm - WARNING - Snapshot: $Snapshot"
$report.add($body10)
}
else {
$body10 = "$vm - OK - No Snapshot"
$report.add($body10)
}

######## ISO
$ISO = ($gvm | select-object @{Label="ISO"; Expression = {($_ | Get-CDDrive).ISOPath}}).ISO
if ($ISO){
$body20 = "$vm - WARNING - ISO: $ISO"
$report.add($body20)
}
else {
$body20 = "$vm - OK - No ISO"
$report.add($body20)}

######## VMTools
$VMtools = ($gvm).extensiondata.Guest.ToolsStatus
if ($VMtools -like "toolsOk" -or $VMtools -like "toolsOld") {
$body30 = "$vm - OK - VMware Tools Status: $VMtools "
$report.add($body30)
}
else {
$body30 = "$vm - WARNING - Tools: $VMtools"
$report.add($body30)
}

######## SRM Replication
$vmv = Get-View $gvm
$dest = $vmv.config.ExtraConfig | select | where {$_.key -eq “hbr_filter.destination”}
If (($dest) -and ($dest.Value)) {
$body40 = "$vm - WARNING -  VM is replicated with SRM"
$report.add($body40)
}
else {
$body40 = "$vm - OK - No SRM Replication"
$report.add($body40)
}


####### Largest VMDK
$LargestVMDKname = ($vmv.LayoutEx.file | Sort-Object Size -Descending | select name,size -first 1).name
$LargestVMDKGB = [Math]::Round(($vmv.LayoutEx.file | Sort-Object Size -Descending | select name,size -first 1).size/1GB,0)
if ($LargestVMDKGB -lt "3600") {
$body50 = "$vm - OK - Largest VMDK is below 3.6TB: $LargestVMDKGB GB"
$report.add($body50)
}
else {
$body50 = "$vm - WARNING - Largest VMDK is more than 3.6TB! $LargestVMDKGB GB, Name: $LargestVMDKname"
$report.add($body50)
}



####### Add line between each Server
$body100 = "----------------------------------------------"
$report.add($body100)
}
$body10 = $report | Out-string


#Send Mail



$body01 = "============================================"
$Body = "$body00`n$body01`n$body10"

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
}
