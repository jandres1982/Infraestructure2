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