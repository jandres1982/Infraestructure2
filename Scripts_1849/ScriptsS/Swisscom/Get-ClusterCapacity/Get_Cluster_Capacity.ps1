#===================================================================================#
#                                                                                   #
# Get_Cluster_Capacity.ps1                                                          #
# Powershell Script to get CPU and Memory allocation on SCC VxBlock                 #
#                                                                                   #
# Author: Erich Niffeler                                                            #
# Creation Date: 27.05.2016                                                         #
# Modified Date: 22.10.2016                                                         #
# Version: 01.00.00                                                                 #
#                                                                                   #
# Example: $PW = powershell.exe D:\Scripts\Swisscom\CPULimit\Get_Cluster_Capacity.ps1  #
#                                                                                   #
#                                                                                   #
# Return                                                                            #
#                                                                                   #
#===================================================================================#


function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "SA-PF01-vCSchiRO@itoper.local"
$Path = "D:\Scripts\Swisscom\Get-ClusterCapacity\"
$CredsFile = "$Path$AdminName-VCCreds_RO.txt"

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
#$username = $cred.GetNetworkCredential().username
#$password = $cred.GetNetworkCredential().password
Return $cred
}#end function


function Get-CPUOvercommit {
<#
.SYNOPSIS
    Obtains the number of vCPUs and the number of physical CPU cores for one or more ESXi hosts and compares them to evaluate CPU overcommitment.

.DESCRIPTION
    Obtains the number of vCPUs and the number of physical CPU cores for one or more ESXi hosts (or for a cluster if the Cluster parameter is used) and compares them to evaluate CPU overcommitment.
    The CPU overcommitment is evaluated by comparing the number of vCPUs of all the running VMs for each ESXi host and the number of physical cores on this host.

.PARAMETER VIServer
    To specify the vCenter Server to connect PowerCLI to.
    The default is Localhost.

.PARAMETER VMhosts
    To specify one or more ESXi hosts.
    The default will query all ESXi hosts managed by the vCenter Server you are connected to in PowerCLI.
    This parameter has 2 aliases : "Hosts" and "Servers".

.PARAMETER Cluster
    Outputs global values for the specified cluster

.PARAMETER Quiet
    This mode only outputs a boolean value for each ESXi host (or for the cluster if the Cluster parameter is used) :
    $True if there is overcommitment, $False if not.

.EXAMPLE 
    Get-CPUOvercommit -Cluster Production

    Obtains vCPU, physical cores and overcommitment information, providing global values for the cluster called Production.

.EXAMPLE 
    Get-VMHost EsxDev5* | Get-CPUOvercommit

    Obtains vCPU, physical cores and overcommitment information for each ESXi host with a name starting with EsxDev5, using pipeline input.

.EXAMPLE
    Get-CPUOvercommit -Quiet

    Outputs a boolean value stating whether there is CPU overcommitment or not, for each ESXi host managed by the connected vCenter Server.
  #>
    [cmdletbinding()]
    param(
    [string]$VIServer = "localhost",
    [Parameter(ValueFromPipeline = $True,
    ValueFromPipelineByPropertyName=$True,
    Position=0)]
    [Alias('Hosts','Servers')]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$VMhosts,
    [string]$Cluster,
    [switch]$Quiet
    )

    Begin {
        if(-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
            Add-PSSnapin VMware.VimAutomation.Core }

        Set-PowercliConfiguration -InvalidCertificateAction "Ignore" -DisplayDeprecationWarnings:$false -Confirm:$false | Out-Null

        If (-not($defaultVIServer)) {
            Connect-VIServer $VIServer
        }
        Else {
            Write-Verbose "Already connected the vCenter Server: $defaultVIServer" 
        }
        # Clearing the default parameter values in the function's scope
        $PSDefaultParameterValues.Clear()
        
        If (-not ($PSBoundParameters.ContainsKey('VMhosts')) ) {
            $VMhosts = Get-VMHost
        }
        # Getting all hosts from the cluster(s) if the -Cluster parameter is specified
        If ($PSBoundParameters.ContainsKey('Cluster')) {
            $VMhosts = Get-Cluster -Name $Cluster | Get-VMHost
        }
        # Preparing a collection to store information for each individual ESXi host
        $OvercommitInfoCollection = @()
    }
    Process {

        Foreach ($VMhost in $VMhosts) {
            
            $HostPoweredOnvCPUs = (Get-VM -Location $VMhost | Where-Object {$_.PowerState -eq "PoweredOn" } | Measure-Object NumCpu -Sum).Sum
            Write-Verbose "`$HostPoweredOnvCPUs for $VMhost is : $HostPoweredOnvCPUs"

            # Building the properties for our custom object            
            $OvercommitInfoProperties = [ordered]@{'ESXi Host'=$VMhost.Name                    
                    'CPU Cores'=$VMhost.NumCpu
                    'Total vCPUs'=(Get-VM -Location $VMhost | Measure-Object NumCpu -Sum).Sum
                    'PoweredOn vCPUs'=if ($HostPoweredOnvCPUs) {$HostPoweredOnvCPUs} Else { 0 -as [int] }
                    'vCPU/Core ratio'=if ($HostPoweredOnvCPUs) {[Math]::Round(($HostPoweredOnvCPUs / $VMhost.NumCpu), 3)} Else { $null }
                    'CPU Overcommit (%)'=if ($HostPoweredOnvCPUs) {[Math]::Round(100*(($HostPoweredOnvCPUs - $VMhost.NumCpu) / $VMhost.NumCpu), 3)} Else { $null }
                    }           

            # Building a custom object from the list of properties above
            $OvercommitInfoObj = New-Object -TypeName PSObject -Property $OvercommitInfoProperties

            If ($Quiet) {
                $OvercommitInfoBoolean = $HostPoweredOnvCPUs -gt $VMhost.NumCpu
                $OvercommitInfoCollection += $OvercommitInfoBoolean
            }            
            Else {  
                $OvercommitInfoCollection += $OvercommitInfoObj
            }
        }
    }
    End {
        If ($PSBoundParameters.ContainsKey('Cluster')) {

            $ClusterPoweredOnvCPUs = (Get-VM -Location $Cluster | Where-Object {$_.PowerState -eq "PoweredOn" } | Measure-Object NumCpu -Sum).Sum
            $ClusterCPUCores = ($VMhosts | Measure-Object NumCpu -Sum).Sum
            Write-Verbose "`$ClusterPoweredOnvCPUs for $Cluster is : $ClusterPoweredOnvCPUs"
            Write-Verbose "`$ClusterCPUCores for $Cluster is : $ClusterCPUCores"

            # Building a custom object specific to the -Cluster parameter
            $ClusterOvercommitProperties = [ordered]@{'Cluster Name'=$Cluster                    
                    'CPU Cores'=$ClusterCPUCores
                    'Total vCPUs'=($OvercommitInfoCollection."Total vCPUs" | Measure-Object -Sum).Sum
                    'PoweredOn vCPUs'=if ($ClusterPoweredOnvCPUs) {$ClusterPoweredOnvCPUs} Else { 0 -as [int] }
                    'vCPU/Core ratio'=if ($ClusterPoweredOnvCPUs) {[Math]::Round(($ClusterPoweredOnvCPUs / $ClusterCPUCores), 3)} Else { $null }
                    'CPU Overcommit (%)'=if ($ClusterPoweredOnvCPUs) {[Math]::Round(100*(( $ClusterPoweredOnvCPUs - $ClusterCPUCores) / $ClusterCPUCores), 3)} Else { $null }
                    }     
            
            $ClusterOvercommitObj = New-Object -TypeName PSObject -Property $ClusterOvercommitProperties

            If ($Quiet) {
                $ClusterOvercommitBoolean = $ClusterPoweredOnvCPUs -gt $ClusterCPUCores
                $ClusterOvercommitBoolean
            }
            
            Else { $ClusterOvercommitObj
            }
        }
        Else { $OvercommitInfoCollection }
    }
}


function Get-MemoryOvercommit {
<#
.SYNOPSIS
    Obtains physical memory and virtual memory information for one or more ESXi hosts and compares them to evaluate memory overcommitment.


.DESCRIPTION
    Obtains physical memory and virtual memory information for one or more ESXi hosts (or for a cluster if the Cluster parameter is used) and compares them to evaluate memory overcommitment.
    The memory overcommitment is evaluated by comparing the memory allocated to the running VMs for each ESXi host and the physical RAM on this host.

.PARAMETER VIServer

    To specify the vCenter Server to connect PowerCLI to.
    The default is Localhost.

.PARAMETER VMhosts
    To specify one or more ESXi hosts.
    The default will query all ESXi hosts managed by the vCenter Server you are connected to in PowerCLI.
    This parameter has 2 aliases : "Hosts" and "Servers".

.PARAMETER Cluster
    Outputs global values for the specified cluster

.PARAMETER Quiet
    This mode only outputs a boolean value for each ESXi host (or for the cluster if the Cluster parameter is used) :
    $True if there is overcommitment, $False if not.

.EXAMPLE 
    Get-MemoryOvercommit -Cluster Production

    Obtains physical RAM, vRAM and overcommitment information, providing global values for the cluster called Production.

.EXAMPLE 
    Get-VMHost EsxDev5* | Get-MemoryOvercommit
    Obtains physical RAM, vRAM and overcommitment information for each ESXi host with a name starting with EsxDev5, using pipeline input.

.EXAMPLE
    Get-MemoryOvercommit -Quiet
    Outputs a boolean value stating whether there is RAM overcommitment or not, for each ESXi host managed by the connected vCenter Server.
  #>
    [cmdletbinding()]
    param(
    [string]$VIServer = "localhost",
    [Parameter(ValueFromPipeline = $True,
    ValueFromPipelineByPropertyName=$True,
    Position=0)]
    [Alias('Hosts','Servers')]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl[]]$VMhosts,
    [string]$Cluster,
    [switch]$Quiet
    )

    Begin {
        if(-not (Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue)) {
            Add-PSSnapin VMware.VimAutomation.Core }

#        Set-PowercliConfiguration -InvalidCertificateAction "Ignore" -DisplayDeprecationWarnings:$false -Confirm:$false | Out-Null

        If (-not($defaultVIServer)) {
            Connect-VIServer $VIServer
        }
        Else {
            Write-Verbose "Already connected the vCenter Server: $defaultVIServer" 
        }
        # Clearing the default parameter values in the function's scope
        $PSDefaultParameterValues.Clear()
        
        If (-not ($PSBoundParameters.ContainsKey('VMhosts')) ) {
            $VMhosts = Get-VMHost
        }
        # Getting all hosts from the cluster(s) if the -Cluster parameter is specified
        If ($PSBoundParameters.ContainsKey('Cluster')) {
            $VMhosts = Get-Cluster -Name $Cluster | Get-VMHost
        }
        # Preparing a collection to store information for each individual ESXi host
        $OvercommitInfoCollection = @()
    }

    Process {

        Foreach ($VMhost in $VMhosts) {
            
            $PhysRAM = [Math]::Round($VMhost.MemoryTotalGB, 2)
            $HostPoweredOnvRAM = [Math]::Round((Get-VM -Location $VMhost | Where-Object {$_.PowerState -eq "PoweredOn" } | Measure-Object MemoryGB -Sum).Sum, 2)
            Write-Verbose "`$PhysRAM for $VMhost is : $PhysRAM"
            Write-Verbose "`$HostPoweredOnvRAM for $VMhost is : $HostPoweredOnvRAM"

            # Building the properties for our custom object
            $OvercommitInfoProperties = [ordered]@{'ESXi Host'=$VMhost.Name                    
                    'Physical RAM (GB)'=$PhysRAM
                    'Total vRAM (GB)'=[Math]::Round((Get-VM -Location $VMhost | Measure-Object MemoryGB -Sum).Sum, 2)
                    'PoweredOn vRAM (GB)'=if ($HostPoweredOnvRAM) {$HostPoweredOnvRAM} Else { 0 -as [int] }
                    'vRAM/Physical RAM ratio'=if ($HostPoweredOnvRAM) {[Math]::Round(($HostPoweredOnvRAM / $PhysRAM), 3)} Else { $null }
                    'RAM Overcommit (%)'=if ($HostPoweredOnvRAM) {[Math]::Round(100*(($HostPoweredOnvRAM - $PhysRAM) / $PhysRAM), 2)} Else { $null }
                    }           

            # Building a custom object from the list of properties above
            $OvercommitInfoObj = New-Object -TypeName PSObject -Property $OvercommitInfoProperties

            If ($Quiet) {
                $OvercommitInfoBoolean = $HostPoweredOnvRAM -gt $PhysRAM
                $OvercommitInfoCollection += $OvercommitInfoBoolean
            }
            Else {  
                $OvercommitInfoCollection += $OvercommitInfoObj
            }
        }
    }
    End {
        If ($PSBoundParameters.ContainsKey('Cluster')) {

            $ClusterPoweredOnvRAM = [Math]::Round((Get-VM -Location $Cluster | Where-Object {$_.PowerState -eq "PoweredOn" } | Measure-Object MemoryGB -Sum).Sum, 2)
            $ClusterPhysRAM = [Math]::Round(($VMhosts | Measure-Object MemoryTotalGB -Sum).Sum, 2)
            Write-Verbose "`$ClusterPoweredOnvRAM for $Cluster is : $ClusterPoweredOnvRAM"
            Write-Verbose "`$ClusterPhysRAM for $Cluster is : $ClusterPhysRAM"

            # Building a custom object specific to the -Cluster parameter
            $ClusterOvercommitProperties = [ordered]@{'Cluster Name'=$Cluster                    
                    'Physical RAM (GB)'=$ClusterPhysRAM
                    'Total vRAM (GB)'=[Math]::Round(($OvercommitInfoCollection."Total vRAM (GB)" | Measure-Object -Sum).Sum, 2)
                    'PoweredOn vRAM (GB)'=if ($ClusterPoweredOnvRAM) {$ClusterPoweredOnvRAM} Else { 0 -as [int] }
                    'vRAM/Physical RAM ratio'=if ($ClusterPoweredOnvRAM) {[Math]::Round(($ClusterPoweredOnvRAM / $ClusterPhysRAM), 3)} Else { $null }
                    'RAM Overcommit (%)'=if ($ClusterPoweredOnvRAM) {[Math]::Round(100*(( $ClusterPoweredOnvRAM - $ClusterPhysRAM) / $ClusterPhysRAM), 2)} Else { $null }
                    }     
            
            $ClusterOvercommitObj = New-Object -TypeName PSObject -Property $ClusterOvercommitProperties

            If ($Quiet) {
                $ClusterOvercommitBoolean = $ClusterPoweredOnvRAM -gt $ClusterPhysRAM
                $ClusterOvercommitBoolean
            }
            
            Else { $ClusterOvercommitObj
            }
        }
        Else { $OvercommitInfoCollection }
    }
}


function Get-ClusterResValue {
[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$false,
                ParameterSetName='ClusterName',
                HelpMessage="Cluster Name to count vCPU of all VM's")]
                $Clustername
)
$ResValue = @()
$Cluster = Get-Cluster -Name $Clustername
$MemoryTotalGB = 0
$MemoryUsageGB = 0
$CpuUsageMhz = 0
$CpuTotalMhz = 0
$NumCPU = 0

$Hosts = $Cluster | Get-VMHost
Foreach ($VMHost in $Hosts) {
  $MemoryTotalGB += $VMHost.MemoryTotalGB
  $MemoryUsageGB += $VMHost.MemoryUsageGB
  $CpuTotalMhz += $VMHost.CpuTotalMhz
  $CpuUsageMhz += $VMHost.CpuUsageMhz
  $NumCPU += $VMHost.NumCpu

}
$MemoryUsageP = [math]::Round($MemoryUsageGB / $MemoryTotalGB * 100)
$CpuUsageP = [math]::Round($CpuUsageMhz / $CpuTotalMhz * 100)

$ResValue = "" | select MemoryTotalGB, MemoryUsageGB, MemoryUsageP, HostCpuMhz, CpuTotalMhz, CpuUsageMhz, CpuUsageP, NumCPU
$ResValue.MemoryTotalGB = [math]::Round($MemoryTotalGB)
$ResValue.MemoryUsageGB = [math]::Round($MemoryUsageGB)
$ResValue.MemoryUsageP = $MemoryUsageP
$ResValue.HostCpuMhz = $CpuTotalMhz / $NumCPU
$ResValue.CpuTotalMhz = $CpuTotalMhz
$ResValue.CpuUsageMhz = $CpuUsageMhz
$ResValue.CpuUsageP = $CpuUsageP
$ResValue.NumCPU = $NumCPU
Return,$ResValue

}#end function


function Get-ClusterStatistic {
[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$false,
                ParameterSetName='ClusterName',
                HelpMessage="Cluster Name to retive Cluster Statistics")]
                $Clustername
)
		$cluster = Get-cluster $clustername
		$Clusters = Get-cluster $cluster | Get-View 
		IF ($cluster | Get-VMHost | Select-Object Count) {
			$Clusters | % {
			$VMHostsView = $null
			$VMHostsView = Get-View $_.Host -Property Name, Hardware, Config
			$VMss         = $cluster | Get-VM
			$HostCount        = ($VMHostsView | Measure-Object).Count
 
				IF ($HostCount -gt 0){
					$VMCount          = 0 + ($VMss | Measure-Object).Count
					IF ($VMCount){
                        $NumEffectiveHosts = [math]::round(($cluster | Get-View).Summary.NumEffectiveHosts, 0) 
						$VMsPerHost       = [math]::round(($VMCount/$NumEffectiveHosts), 1)
						$vCPU             = 0 + ($VMss | measure-object -sum -property NumCPU).Sum
						$allocatedram      = 0 + ($VMss | measure-object -sum -property memorygb).Sum
						$avgrampervm      = [math]::round(($allocatedram/$VMCount), 1)
						$pCPUSocket       = ($VMHostsView | % { $_.Hardware.CPUInfo.NumCpuPackages } | Measure-Object -sum).Sum
						$TpCPUSocket      = $pCPUSocket
						$pCPUCore         = ($VMHostsView | % { $_.Hardware.CPUInfo.NumCpuCores } | Measure-Object -sum).Sum
						$CPUSpeed = ($VMHostsView |% {[math]::round($_.Hardware.CpuInfo.Hz / 1000000, 0)}| Measure-Object -sum).Sum
						$OverallCPUSpeed = ($CPUSpeed / $HostCount)
						$TotalCPU = [math]::round(($cluster | Get-View).Summary.TotalCpu, 0) 

                        $ReservedCPUMHz = (($VMss | Get-VMResourceConfiguration).CPUReservationMhz | Measure-Object -sum).Sum
						$ReservedCPUPercent  = [math]::round(($ReservedCPUMHz/$TotalCPU*100), 0)

                        $ClusterCPULimitMHz = (Get-Cluster $cluster | Get-ResourcePool -Name "Resources").CpuLimitMHz
                        $ResPoolCPULimitMHz = ((Get-Cluster $cluster | Get-ResourcePool -Name "RP_SCH*").CpuLimitMHz | Measure-Object -sum).Sum
                        $ResPoolCPULimitPercent = [math]::round(($ResPoolCPULimitMHz/$ClusterCPULimitMHz*100), 0)

						$vCPUPerpCPUCore  = [math]::round(($vCPU/$pCPUCore), 1)
						$TotalClusterRAMGB =[math]::round((Get-cluster $cluster | get-vmhost | % { $_ } | measure-object -property memorytotalGB -sum).sum)
						$EffectiveClusterRAMGB =[math]::round((($cluster | Get-View).Summary.EffectiveMemory / 1KB), 0)
						$ClusterPoweredOnAllocatedRAMGB = [Math]::Round(($VMss | Where-Object {$_.PowerState -eq "PoweredOn" } | Measure-Object MemoryGB -Sum).Sum, 0)
						$TotalClusterRAMAllocatedPercent = [math]::round(($ClusterPoweredOnAllocatedRAMGB/$EffectiveClusterRAMGB)*100)
                        $TotalClusterRAMusageGB =[math]::round((Get-cluster $cluster | get-vmhost | % { $_ } | measure-object -property memoryusageGB -sum).sum)
						$TotalClusterRAMUsagePercent = [math]::round(($TotalClusterRAMusageGB/$EffectiveClusterRAMGB)*100)
						$TotalClusterRAMFreeGB = [math]::round(($EffectiveClusterRAMGB-$TotalClusterRAMUsageGB))
						$TotalClusterRAMReservedGB = [math]::round(($EffectiveClusterRAMGB/100)*15)
						$TotalClusterRAMAvailable = [math]::round(($TotalClusterRAMFreeGB-$TotalClusterRAMReservedGB))
						$newvmcount = [math]::round(($TotalClusterRAMAvailable/$avgrampervm))
 
						$ClusterStatistc = New-Object PSObject |
						Add-Member -pass NoteProperty "ClusterName" $cluster.name    |
						Add-Member -pass NoteProperty "TotalCluster Host Count" $HostCount    |
						Add-Member -pass NoteProperty "TotalCluster Effective Host Count" $NumEffectiveHosts    |
						Add-Member -pass NoteProperty "TotalCluster VM Count" $VMCount    |
						Add-Member -pass NoteProperty "TotalCluster VM/Host" $VMsPerHost    |
						Add-Member -pass NoteProperty "TotalCluster pCPUSocket" $TpCPUSocket   |
						Add-Member -pass NoteProperty "TotalCluster pCPU Cores" $pCPUCore   |
						Add-Member -pass NoteProperty "TotalCluster vCPU Count" $VCPU    |
						Add-Member -pass NoteProperty "TotalCluster vCPU/pCPUCore" $vcpuperpcpucore  |
						Add-Member -pass NoteProperty "TotalCluster CPU (MHz)" $TotalCPU |
						Add-Member -pass NoteProperty "TotalCluster CPU Reserved (MHz)" $ReservedCPUMHz  |
						Add-Member -pass NoteProperty "TotalCluster CPU Reserved (%)" $ReservedCPUPercent  |
						Add-Member -pass NoteProperty "TotalCluster CPU Effective (MHz)" $ClusterCPULimitMHz  |
						Add-Member -pass NoteProperty "TotalResPool CPU Limit (MHz)" $ResPoolCPULimitMHz  |
						Add-Member -pass NoteProperty "TotalResPool CPU Limit (%)" $ResPoolCPULimitPercent  |
						Add-Member -pass NoteProperty "CPU Speed Processor (MHz)" $OverallCPUSpeed  |
						Add-Member -pass NoteProperty "TotalCluster RAM (GB)" $TotalClusterRAMGB    |
						Add-Member -pass NoteProperty "TotalCluster Effective RAM (GB)" $EffectiveClusterRAMGB    |
						Add-Member -pass NoteProperty "TotalCluster RAM Allocated poweredOn VMs (GB)" $ClusterPoweredOnAllocatedRAMGB    |
						Add-Member -pass NoteProperty "TotalCluster RAM Allocated (%)" $TotalClusterRAMAllocatedPercent    |
						Add-Member -pass NoteProperty "TotalCluster RAM Usage (GB)" $TotalClusterRAMusageGB    |
						Add-Member -pass NoteProperty "TotalCluster RAM USAGE (%)"  $TotalClusterRAMUsagePercent    |
						Add-Member -pass NoteProperty "TotalCluster RAM Free (GB)"  $TotalClusterRAMfreeGB    |
						Add-Member -pass NoteProperty "TotalCluster RAM Reserved (GB) (15%)" $TotalClusterRAMReservedGB    |
						Add-Member -pass NoteProperty "RAM Available for NEW VMs in (GB)" $TotalClusterRAMAvailable    |
						Add-Member -pass NoteProperty "Allocated RAM per VM on an average (GB)" $avgrampervm    |
						Add-Member -pass NoteProperty "NEW VM's that can be provisioned based on Average RAM per VM" $newvmcount	
            
                        Return,$ClusterStatistc
					}
				}
			}
		}
 }#end function 




# ******* MAIN SCIPT 
# Connect to vCenter
Add-PSSnapin -Name VMware*
$VIServer = "vcenterscs.global.schindler.com"
$Credentials = Get-VCCredential
Connect-VIServer -Server $VIServer -Credential $Credentials

# Declaration of variables
$OFS = "`r`n"
$BodyText = @"
This mail has been generated automatically by a scheduled task.
Please, do not reply.
"@
$PSEmailServer = "smtp.eu.schindler.com"
$From = "vcenterscs@ch.schindler.com"
$To = "scc.support@ch.schindler.com","Capacity.Planning@swisscom.com"
$BCC = "Erich.Niffeler@swisscom.com"
$Date = Get-date -Format "yyyy-MM-d"
$LogFileName = "ClusterStatistic-$Date.log"
$HTMLFileName = "ClusterStatistic-$Date.html"
$AlertFile = "AlertSent.log"
$LogPath = "D:\Scripts\Swisscom\Get-ClusterCapacity\"
$Logfile="$LogPath$LogFileName"
$HTMLfile="$LogPath$HTMLFileName"

$Clusters = Get-Cluster | Sort Name
$Date = Get-Date 
$Date | Out-File -FilePath $Logfile -Force
$HTML = "<b>$BodyText</b>`n<br>"
$HTML += "`n<b>$Date</b><br>"

Foreach ($Cluster in $Clusters){
   $Statistics = Get-ClusterStatistic $Cluster 
   if ($Statistics -ne $null) {
    $Statistics | Out-File -FilePath $Logfile -Append
    $HTML += "`n<br>"
    $HTML += $Statistics | ConvertTo-Html -As List -Fragment
   } 
} 

$Message = ConvertTo-Html -Body "$HTML" -Title "Cluster Statistics" 
$Message | Out-File -FilePath $HTMLfile

#Send Mail with Statistics
$Subject = "ClusterStatistics VxBlock $Date "

Send-MailMessage -From $From -To $To -Bcc $BCC -Subject $Subject -BodyAsHtml "$Message"




