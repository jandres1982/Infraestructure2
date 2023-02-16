function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "SA-PF01-vCSchiVMA@itoper.local"
$Path = "D:\Scripts\Swisscom\\SetVMReservation\"
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
#$username = $cred.GetNetworkCredential().username
#$password = $cred.GetNetworkCredential().password
Return $cred
}#end function

function Set-VMResValue {
[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$true,
                ParameterSetName='VMName',
                HelpMessage="VM Name to count vCPU and set reservation for VM")]
                $VMname
)

$VM = Get-VM -Name $VMName
$ESXHost = $VM.VMHost
$CPUMhzCore = ($ESXHost.CpuTotalMhz / $ESXHost.NumCpu)
$CPUMhzvCPU = $CPUMhzCore/2
$Reservation = $VM.NumCpu * $CPUMhzvCPU
$VM | Get-VMResourceConfiguration | Set-VMResourceConfiguration -CpuReservationMhz $Reservation
}#end function

function Get-VMResValue {
[cmdletBinding()]
param(
<#     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$true,
                ParameterSetName='VMName',
                HelpMessage="VM Name to count vCPU and set reservation for VM")]
                $VMname
#>
)

$Clusters = Get-Cluster "SCH-ITBC-01*"
Foreach ($cluster in $Clusters) {
  $ResSum = 0
  $VMs = $cluster | Get-VM
  "=== Cluster: $($Cluster.name)" 
  Foreach ($VM in $VMs) {
    $Reservation = ($VM | Get-VMResourceConfiguration).CpuReservationMhz
    if ($Reservation -ne 0) {
      $ResSum += $Reservation
      "$($VM.name) $Reservation"
    }
  }
$ClusterTotalCpuMHz = ($cluster | Get-View).Summary.TotalCpu
$ResP = [math]::Round($ResSum / $ClusterTotalCpuMHz * 100)
"Cluster Total CPU (MHz) : $ClusterTotalCpuMHz"
"Total Reservation (MHz) : $ResSum"
"Reservation (%)         : $ResP"
}
}#end function


# Connect to vCenter
Add-PSSnapin -Name VMware*
$VIServer = "vcenterscs.global.schindler.com"
$Credentials = Get-VCCredential
Connect-VIServer -Server $VIServer -Credential $Credentials

# Declaration of variables
# Set-VMResValue -VMname "Test-VM"

# Function

