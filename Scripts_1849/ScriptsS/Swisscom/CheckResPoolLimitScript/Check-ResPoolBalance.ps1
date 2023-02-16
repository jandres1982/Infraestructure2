function Check-ResPoolBalance {
[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$false,
                ParameterSetName='ResPoolName',
                HelpMessage="ResPool Name to count vCPU of all VM's")]
                $ResPoolName
)

#initialize variables
$VMLocationList = @()
$CPUcountSta59 = 0
$CPUcountInd30 = 0
$CPUcountElse = 0

$ResPool = Get-ResourcePool -Name $ResPoolName
$VMS = $ResPool | Get-VM | where {$_.PowerState -eq "PoweredOn"}

if ($VMS -ne $null){
    foreach ($VM in $VMS){
       $Obj = "" | Select Name,Location,CPUcount
       $Obj.Name = $VM.Name
       $Obj.Location = ($VM.VMHost | Get-Annotation -CustomAttribute Location).Value
       $Obj.CPUcount = $VM.NumCpu
       $VMLocationList += $Obj
       Switch ($Obj.Location){
         Sta59 {$CPUcountSta59 += $VM.NumCpu}
         Ind30 {$CPUcountInd30 += $VM.NumCpu}
         default {$CPUcountElse += $VM.NumCpu}
       }
    }
    "CPUCount Sta59 = $CPUcountSta59"
    "CPUCount Ind30 = $CPUcountInd30"
    "CPUCount Else = $CPUcountElse"
    Return $VMLocationList
}
}#End Function Check-ResPoolBalance

#Get-ResourcePool -Name RP_SCH-ITBC-01_CR1 | Get-VM | foreach {((Get-VM -Name $_).VMHost | Get-Annotation -CustomAttribute Location).Value}

