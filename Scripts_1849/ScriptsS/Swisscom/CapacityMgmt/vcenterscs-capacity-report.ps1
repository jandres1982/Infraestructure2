#===================================================================================#
#                                                                                   #
# vcenterscs-capacity-report.ps1                                                    #
# Description....
#                                                                                   #
# Author: Michael Barmettler                                                        #
# Creation Date: 14.10.2016                                                         #
# Modified Date:                                                                    #
# Version: 01.01.00                                                                 #
#                                                                                   #
# Example: powershell.exe .\VM-Placement-Alerting.ps1                               #
#                                                                                   #
#===================================================================================#



function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "SA-PF01-vCSchiRO@itoper.local"
$Path = "D:\Scripts\Swisscom\CapacityMgmt\"
$CredsFile = "$Path$AdminName-VCCreds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
    $Cred = Get-Credential -Message "VCenterSCS Credentials" -UserName $username
    $Cred.Password | ConvertFrom-SecureString | Out-File $CredsFile
}
else
    {Write-Host 'Using your stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password}

sleep 2
Return $cred
} #function to get and store the vCenter credentials

################################################################################################
# Connect to vCenterSCS
Add-PSSnapin -Name VMware*
$VIServer = "vcenterscs.global.schindler.com"
$Credentials = Get-VCCredential
Connect-VIServer -Server $VIServer -Credential $Credentials

#Get all VMs in vCenter and query name, location, custer, vCPUs, Memory, MemGuestActive, Path

#$vms = Get-vm | select name,numcpu,memorymb,vmhost,@{n="ResourcePool"; e={$_ | Get-ResourcePool}}, @{n="Cluster"; e={$_ | Get-Cluster}},@{n="Datastore"; e={$_ | Get-Datastore}}, @{n="Location"};e={$_ | get-vmhost | select -expandproperty customfields | where {$_.Key -eq "Location"}}


#########################################################
# 1. Get a list of VMs and Hosts

$hosts = Get-View -ViewType Hostsystem | Select-Object -Property name,
        @{N="HostID";E={$_.moref.value}},
        @{N="Annotation";E={($_.summary.customvalue | Where-Object {$_.Key -like "101"}).value}},
        @{N="MaintenanceMode";E={$_.runtime.InMaintenanceMode}},
        @{N="ConnectionState";E={$_.runtime.ConnectionState}},
        @{N="Sockets";E={$_.hardware.cpuinfo.numcpupackages}},
        @{N="CoresperSocket";E={$_.hardware.cpuinfo.numcpucores/$_.hardware.cpuinfo.numcpupackages}},
        @{N="TotalCores";E={$_.hardware.cpuinfo.numcpucores}},
        @{N="CPU_MHz";E={[math]::Round($_.hardware.cpuinfo.hz/1000000,2)}},
        @{N="Mem_Size_MB";E={[math]::Round($_.hardware.memorysize/1MB,0)}},
        @{N="Powerstate";E={$_.runtime.powerstate}},
        @{N="Cluster";E={$parent = Get-View -Id $_.Parent -Property Name,Parent
        While ($parent -isnot [VMware.Vim.ClusterComputeResource] -and $parent.Parent){$parent = Get-View -Id $parent.Parent -Property Name,Parent}
        if($parent -is [VMware.Vim.ClusterComputeResource]){$parent.Name}}}
        


$VMs = Get-View -ViewType VirtualMachine | Select-Object -Property name,
        @{N="HostID";E={$_.runtime.host.value}},
        @{N="Location";E={"unavailable"}},
        @{N="Cluster";E={"unavailable"}},
        @{N="vCPUs";E={$_.config.hardware.NumCPU}},
        @{N="vMem";E={$_.config.hardware.MemoryMB}},
        @{N="GuestMemoryUsage";E={$_.summary.quickstats.guestmemoryusage}},
        @{N="Datastore";E={$_.config.datastoreurl.name}},
        @{N="Powerstate";E={$_.runtime.powerstate}}


foreach ($VM in $VMs) {
    $VM.Location = ($hosts | where-object {$_.HostID -eq $VM.HostID}).Annotation
    $VM.Cluster = ($hosts | where-object {$_.HostID -eq $VM.HostID}).Cluster
}



##############################################
# 2. Calculate Memory and CPU utilization

#Measure vCPU
$SCH_Ind30_01_vCPU = ($VMs | Where-Object {$_.Cluster -eq "SCH-Ind30-01"} | Measure-Object vCPUs -Sum).sum
$SCH_Sta59_01_vCPU = ($VMs | Where-Object {$_.Cluster -eq "SCH-Sta59-01"} | Measure-Object vCPUs -Sum).sum
$SCH_ITBC_01_Sta59_vCPU = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-01" -and $_.Location -eq "Sta59"} | Measure-Object vCPUs -Sum).sum
$SCH_ITBC_01_Ind30_vCPU = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-01" -and $_.Location -eq "Ind30"} | Measure-Object vCPUs -Sum).sum
$SCH_ITBC_SQL_01_Sta59_vCPU = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Location -eq "Sta59"} | Measure-Object vCPUs -Sum).sum
$SCH_ITBC_SQL_01_Ind30_vCPU = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Location -eq "Ind30"} | Measure-Object vCPUs -Sum).sum

#Measure vMem
$SCH_Ind30_01_vMem = ($VMs | Where-Object {$_.Cluster -eq "SCH-Ind30-01"} | Measure-Object vMem -Sum).sum
$SCH_Sta59_01_vMem = ($VMs | Where-Object {$_.Cluster -eq "SCH-Sta59-01"} | Measure-Object vMem -Sum).sum
$SCH_ITBC_01_Sta59_vMem = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-01" -and $_.Location -eq "Sta59"} | Measure-Object vMem -Sum).sum
$SCH_ITBC_01_Ind30_vMem = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-01" -and $_.Location -eq "Ind30"} | Measure-Object vMem -Sum).sum
$SCH_ITBC_SQL_01_Sta59_vMem_ITBC = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Location -eq "Sta59" -and $_.Datastore -like "*DS*"} | Measure-Object vMem -Sum).sum
$SCH_ITBC_SQL_01_Ind30_vMem_ITBC = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Location -eq "Ind30" -and $_.Datastore -like "*DS*"} | Measure-Object vMem -Sum).sum
$SCH_ITBC_SQL_01_Sta59_vMem_SS = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Location -eq "Sta59" -and $_.Datastore -notlike "*DS*"} | Measure-Object vMem -Sum).sum
$SCH_ITBC_SQL_01_Ind30_vMem_SS = ($VMs | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Location -eq "Ind30" -and $_.Datastore -notlike "*DS*"} | Measure-Object vMem -Sum).sum

#Measure pCPU
$SCH_Ind30_01_pCPU = ($hosts | Where-Object {$_.Cluster -eq "SCH-Ind30-01" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object TotalCores -Sum).sum
$SCH_Sta59_01_pCPU = ($hosts | Where-Object {$_.Cluster -eq "SCH-Sta59-01" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object TotalCores -Sum).sum
$SCH_ITBC_01_Sta59_pCPU = ($hosts | Where-Object {$_.Cluster -eq "SCH-ITBC-01" -and $_.Annotation -eq "Sta59" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object TotalCores -Sum).sum
$SCH_ITBC_01_Ind30_pCPU = ($hosts | Where-Object {$_.Cluster -eq "SCH-ITBC-01" -and $_.Annotation -eq "Ind30" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object TotalCores -Sum).sum
$SCH_ITBC_SQL_01_Sta59_pCPU = ($hosts | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Annotation -eq "Sta59" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object TotalCores -Sum).sum
$SCH_ITBC_SQL_01_Ind30_pCPU = ($hosts | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Annotation -eq "Ind30" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object TotalCores -Sum).sum

#Measure pMem
$SCH_Ind30_01_pMem = ($hosts | Where-Object {$_.Cluster -eq "SCH-Ind30-01" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object Mem_Size_MB -Sum).sum
$SCH_Sta59_01_pMem = ($hosts | Where-Object {$_.Cluster -eq "SCH-Sta59-01" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object Mem_Size_MB -Sum).sum
$SCH_ITBC_01_Sta59_pMem = ($hosts | Where-Object {$_.Cluster -eq "SCH-ITBC-01" -and $_.Annotation -eq "Sta59" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object Mem_Size_MB -Sum).sum
$SCH_ITBC_01_Ind30_pMem = ($hosts | Where-Object {$_.Cluster -eq "SCH-ITBC-01" -and $_.Annotation -eq "Ind30" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object Mem_Size_MB -Sum).sum
$SCH_ITBC_SQL_01_Sta59_pMem = ($hosts | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Annotation -eq "Sta59" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object Mem_Size_MB -Sum).sum
$SCH_ITBC_SQL_01_Ind30_pMem = ($hosts | Where-Object {$_.Cluster -eq "SCH-ITBC-SQL-01" -and $_.Annotation -eq "Ind30" -and $_.ConnectionState -eq "connected" -and $_.MaintenanceMode -like "False"} | Measure-Object Mem_Size_MB -Sum).sum

#Total without Failover
$SCH_ITBC_01_Memory_pct = 100/($SCH_ITBC_01_Sta59_pMem+$SCH_ITBC_01_Ind30_pMem)*($SCH_ITBC_01_Sta59_vMem+$SCH_ITBC_01_Ind30_vMem)
$SCH_Ind30_01_Memory_pct = 100/$SCH_Ind30_01_pMem*$SCH_Ind30_01_vMem
$SCH_Sta59_01_Memory_pct = 100/$SCH_Sta59_01_pMem*$SCH_Sta59_01_vMem
$SCH_ITBC_SQL_01_Sta59_ITBC_available_vMem = $SCH_ITBC_SQL_01_Sta59_pMem-$SCH_ITBC_SQL_01_Sta59_vMem_SS-$SCH_ITBC_SQL_01_Sta59_vMem_ITBC-$SCH_ITBC_SQL_01_Ind30_vMem_ITBC
$SCH_ITBC_SQL_01_Ind30_ITBC_available_vMem = $SCH_ITBC_SQL_01_Ind30_pMem-$SCH_ITBC_SQL_01_Ind30_vMem_SS-$SCH_ITBC_SQL_01_Sta59_vMem_ITBC-$SCH_ITBC_SQL_01_Ind30_vMem_ITBC
Write-host ""
Write-host "$SCH_ITBC_01_Memory_pct % of Physical Memory is allocated on ITBC cluster"
Write-host "$SCH_ITBC_SQL_01_Sta59_ITBC_available_vMem MB of Physical Memory is available on ITBC-SQL Sta59 Side"
Write-host "$SCH_ITBC_SQL_01_Ind30_ITBC_available_vMem MB of Physical Memory is available on ITBC-SQL Sta59 Side"