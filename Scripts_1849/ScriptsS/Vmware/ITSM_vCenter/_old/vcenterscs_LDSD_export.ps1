#===================================================================================#
#                                                                                   #
# vcenterscs_LDSD_export.ps1                                                        #
# Powershell Script to export inventory data from vCenter via PowerCLI.             #
# The script replaces the need for SQL DB Views on the VCDB.                        #
# Author: Michael Barmettler                                                        #
# Creation Date: 06.07.2016                                                         #
# Modified Date: 06.07.2016                                                         #
# Version: 01.00.00                                                                 #
#                                                                                   #
# Example: powershell.exe .\vcenterscs_LDSD_export.ps1                              #
#                                                                                   #
#===================================================================================#

#####################################################################################
#Specify vCenter name and service account (read-only sufficient)
#---------------------------------------------------------------
$vcname = "vcenterscs.global.schindler.com"
$Username = "SA-PF01-vCSchiRO@itoper.local"

#####################################################################################
#Function to store the vCenter credentials in a securestring PScredential file
#------------------------------------------------------------------------------
function Get-VCCredential {
param( )

#initialize variables
#-------------------
$AdminName = $env:USERNAME
$Path = "D:\Scripts\Schindler\Vmware\ITSM_vCenter\"
$CredsFile = "$Path$AdminName-VCCreds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
    $Cred = Get-Credential -Message "$vcname Credentials" -UserName $username
    $Cred.Password | ConvertFrom-SecureString | Out-File $CredsFile
}
else
    {Write-Host 'Using your stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password}

sleep 2
Return $cred
}


#####################################################################################
# Connect to vCenter
#-------------------
Add-PSSnapin -Name VMware*
$vcname
$Credentials = Get-VCCredential
Connect-VIServer -Server $vcname -Credential $Credentials


#####################################################################################
#Get vCenter ID
#--------------
$si = Get-View ServiceInstance
$setting = Get-View $si.Content.Setting
$vcid = $setting.QueryOptions("instance.id") | Select -ExpandProperty Value

#Set time of Inventory
#---------------------
$now = get-date -f "yyyy-MM-dd HH:mm:ss.fff"

#####################################################################################
#LDSD_HostVMList
#---------------
$hosts = Get-View -ViewType Hostsystem | Select-Object -Property @{N="H_NAME";E={$_.Name}},
        @{N="Hostname";E={($_.config.network.dnsconfig.hostname).ToUpper()}},
        @{N="HOST_MODEL";E={$_.hardware.systeminfo.model}},
        @{N="H_enabled";E={"1"}},                  #Host ENABLED??, setting it to 1 since all hosts have it to one in the SQL DB...
        @{N="H_CPUmodel";E={$_.hardware.cpupkg.description[1]}},
        @{N="H_CPUcount";E={$_.hardware.cpuinfo.numcpupackages}},
        @{N="H_CoresSocket";E={$_.hardware.cpuinfo.numcpucores/$_.hardware.cpuinfo.numcpupackages}},
        @{N="H_Corecount";E={$_.hardware.cpuinfo.numcpucores}},
        @{N="HOST_VENDOR";E={$_.hardware.systeminfo.vendor}},
        @{N="H_Host_ID";E={"$vcid$($_.moref.value -replace "\D+")"}},     
        @{N="H_Mem_Size_MB";E={[math]::Round($_.hardware.memorysize/1MB,0)}},
        @{N="H_Powerstate";E={$_.runtime.powerstate}},
        @{N="ClusterName";E={$parent = Get-View -Id $_.Parent -Property Name,Parent
        While ($parent -isnot [VMware.Vim.ClusterComputeResource] -and $parent.Parent){$parent = Get-View -Id $parent.Parent -Property Name,Parent}
        if($parent -is [VMware.Vim.ClusterComputeResource]){$parent.Name}}},
        @{N="MAC_ADDRESS";E={$_.config.network.pnic.mac[0]}},
        @{N="PRODUCT_NAME";E={$_.config.product.name}},
        @{N="PRODUCT_VERSION";E={$_.config.product.Version}},
        @{N="PRODUCT_BUILD";E={$_.config.product.Build}},
        @{N="PRODUCT_OS_TYPE";E={$_.config.product.OsType}},
        @{N="NameVersion";E={"$($_.config.product.name) - $($_.config.product.Version)"}},
        @{N="CPU_GHz";E={[math]::Round($_.hardware.cpuinfo.hz/1000000000,2)}},
        @{N="IP_ADDRESS";E={$_.config.network.vnic.spec.ip.ipaddress[0]}},
        @{N="Inventory_Date";E={$now}},
        @{N="prefix";E={"vC_Host-"}} 
 
#Replace H_Powerstate string with desired string
#----------------------------------------------- 
$hosts | foreach-object {
$_.H_Powerstate = $_.H_Powerstate -replace "poweredOn","On"
$_.H_Powerstate = $_.H_Powerstate -replace "poweredOff","Off"
}

#####################################################################################
#LDSD_ClientInfo
#---------------
$VMs = Get-View -ViewType VirtualMachine -Filter @{'Config.Template'='False';'guest.guestfamily'='WindowsGuest|LinuxGuest'} | Select-Object -Property @{N="DNS_Name";E={$_.Guest.Hostname}},
        @{N="Hostname";E={($_.Name).ToUpper()}},
        @{N="Guest_OS";E={$_.Guest.guestid}},
        @{N="ID";E={"$vcid$($_.summary.vm -replace "\D+")"}},        
        @{N="Host_ID";E={"$vcid$($_.runtime.host -replace "\D+")"}},
        @{N="NUM_VCPU";E={$_.config.hardware.NumCPU}},
        @{N="IP_ADDRESS";E={$_.guest.IpAddress}},
        @{N="G_Mem_MB";E={$_.config.hardware.MemoryMB}},
        @{N="HARDWARE_CORES";E={$_.config.hardware.NumCoresPerSocket}},
        @{N="NumOfSockets";E={$_.config.hardware.NumCPU/$_.config.hardware.NumCoresPerSocket}},
        @{N="G_Powerstate";E={$_.runtime.powerstate}},
        @{N="G_State";E={$_.guest.GuestState}}


#Replace Powerstate string with "bool" string
#---------------------------------------------
$VMs | foreach-object {
$_.G_Powerstate = $_.G_Powerstate -replace "poweredOn","1"
$_.G_Powerstate = $_.G_Powerstate -replace "poweredOff","0"
}

#####################################################################################
#Export to CSV
#-----------------------------------
$hosts | export-csv -NoTypeInformation "\\infv0001.global.schindler.com\Landesk-Exchange\VMware\api_LDSD_HostVMList-$vcname.csv" -force
$VMs | export-csv -NoTypeInformation "\\infv0001.global.schindler.com\Landesk-Exchange\VMware\api_LDSD_ClientInfo-$vcname.csv" -force