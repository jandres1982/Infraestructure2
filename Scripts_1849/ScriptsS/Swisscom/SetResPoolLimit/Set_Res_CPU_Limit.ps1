#===================================================================================#
#                                                                                   #
# SetResCPULimit.ps1                                                                #
# Powershell Script to set CPU Limit on Specified Ressourcepools                    #
# to provide 3 different CPU ratios (1:1;1:2;1:4)                                   #
# Author: Erich Niffeler                                                            #
# Creation Date: 27.05.2016                                                         #
# Modified Date: 18.06.2016                                                         #
# Version: 01.00.00                                                                 #
#                                                                                   #
# Example: $PW = powershell.exe D:\Scripts\Swisscom\CPULimit\SetResCPULimit.ps1     #
#                                                                                   #
#                                                                                   #
# Return                                                                            #
#                                                                                   #
#===================================================================================#


function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "SA-PF01-vCSchiVMA@itoper.local"
$Path = "D:\Scripts\Swisscom\SetResPoolLimit\"
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
}



function Set-ResPoolCPULimit {
[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ValueFromPipeline=$false,
                ParameterSetName='ResPoolName',
                HelpMessage="ResPool Name to count vCPU of all VM's")]
                $ResPoolName,
                [ValidateSet(1,2,4)]
                [int]$Ratio
)

#initialize variables
$CPUcount=0
$BaseLimit = 10000 / $Ratio  # Base CPU Limit - can be removed if Pool has more VM's assigned
#get all VM's of the ressource pool
$ResPool = Get-ResourcePool -Name $ResPoolName
$VMS = $ResPool | Get-VM | where {$_.PowerState -eq "PoweredOn"}
#calculate total of assigned vCPUs
if ($VMS -ne $null){
    foreach ($VM in $VMS){
       $CPUcount+=$VM.NumCpu
       }

    #calculate Limit 
    $ESXHost = $VMS[0].VMhost
    #  check if Hyperthreading active on host of first VM in Resource pool
    $HTactive = $ESXHost.HyperthreadingActive
    #$HTactive = $True # Test without Hyperthreading calculation
    if ($HTactive -eq $True) {$HT=2}
    else {$HT=1}
    
    $CPUMhzCore = ($ESXHost.CpuTotalMhz / $ESXHost.NumCpu)
    [long]$CpuLimitMHz = ($CPUcount * $CPUMhzCore / $Ratio / $HT) + $BaseLimit

    $CpuLimitOldMHz = (Get-ResourcePool -Name $ResPoolName).CpuLimitMHz
    if ($CpuLimitOldMHz -ne $CpuLimitMHz) {
        #the foolowing information is for test purpose and could be written to a log file instead
        "ResPoolName:  $ResPoolName" | Out-File -FilePath $Logfile -Append
        "CPU Ratio:    $Ratio" | Out-File -FilePath $Logfile -Append
        "CPU Count:    $cpucount" | Out-File -FilePath $Logfile -Append
        "CPU MhzCore:  $CPUMhzCore" | Out-File -FilePath $Logfile -Append
        "HT Active:    $HTactive" | Out-File -FilePath $Logfile -Append
        "CPU Limit Mhz:$CpuLimitMHz" | Out-File -FilePath $Logfile -Append
        "Old Limit Mhz:$CpuLimitOldMHz" | Out-File -FilePath $Logfile -Append
        "BaseLimit Mhz:$BaseLimit" | Out-File -FilePath $Logfile -Append 
        " "
 
        #set CPU pool Limit to calculated Limit
        Set-ResourcePool -ResourcePool $ResPoolName -CpuLimitMhz $CpuLimitMHz
    }
    else{
       "ResPoolName:  $ResPoolName CPU Limit has not changed - Limit: $CpuLimitMHz CPU Count: $cpucount" | Out-File -FilePath $Logfile -Append
    }
}
else{
    "ResPoolName:  $ResPoolName has no powered-on VM's" | Out-File -FilePath $Logfile -Append
    $CpuLimitOldMHz = (Get-ResourcePool -Name $ResPoolName).CpuLimitMHz
    if ($CpuLimitOldMHz -ne (-1)) {
        Set-ResourcePool -ResourcePool $ResPoolName -CpuLimitMhz (-1)
    }
} 
}

# Connect to vCenter
Add-PSSnapin -Name VMware*
$VIServer = "vcenterscs.global.schindler.com"
$Credentials = Get-VCCredential
Connect-VIServer -Server $VIServer -Credential $Credentials

# Declaration of variables
$BodyText = @"
This mail is being generated automatically by a scheduled task.
Please, do not reply.
"@
$PSEmailServer = "smtp.eu.schindler.com"
$From = "vcenterscs@ch.schindler.com"
$To = "converged.platforms@swisscom.com", "scc.support@ch.schindler.com", "ServiceManagement.Schindler@swisscom.com"
$ResPoolStartWith = "RP_SCH-*"
$Date = Get-date -Format "yyyy-MM-d"
$LogFileName = "SetCPULimits-$Date.log"
$AlertFile = "AlertSent.log"
$LogPath = "D:\Scripts\Swisscom\SetResPoolLimit\"
$Logfile="$LogPath$LogFileName"
$ValidateSet = @(1,2,4) # Allowed Ratios
$AlertLevel = 70 # Level when CPU Limit is 70 % of available CPU in Mhz
$Clusters = Get-Cluster
$Date=Get-Date
" " | Out-File -FilePath $logfile -Append
"===========================================================================================" | Out-File -FilePath $Logfile -Append
"==== New Run $Date ========================================================== " | Out-File -FilePath $Logfile -Append
# Check when last Alarm has been sent last time
if (Test-Path $LogPath$AlertFile) {
    $Diff= $Date - (Get-Item $LogPath$AlertFile).LastWriteTime
    # Reset Alarm message blocker flag if last alarm has been sent more than x (2) days ago
    if ($Diff.TotalDays -ge 1) {
        remove-item $LogPath$AlertFile
    }
}

Foreach ($Cluster in $Clusters){
    $Logging = $false
    $CPULimitSum = 0
    $ResourcePools = $cluster | Get-ResourcePool -Name $ResPoolStartWith  # Ressource Pool Name starts with
    $Date=Get-Date
    if ($ResourcePools -ne $null){
        "****** Cluster: $cluster $Date *****************************" | Out-File -FilePath $Logfile -Append
        " " | Out-File -FilePath $Logfile -Append
    }

    # Set CPU Limit for each CPU Resource Pool in cluster
    Foreach ($ResPool in $ResourcePools){
       $ResPoolName=($ResPool).name
       $Ratio = $ResPoolName.Substring($ResPoolName.length-1)
       if ($Ratio -in $ValidateSet){
           Set-ResPoolCPULimit -ResPoolName $ResPoolName -Ratio $Ratio
       }
       # Calculate Sum of CPU Limits defined in cluster
       if ($ResPool.CpuLimitMHz -ge 0){
          $CPULimitSum += $ResPool.CpuLimitMHz
       }
       $Logging = $true
    }
    # Write Results to Log 
    if ($Logging -eq $true){
        $ClusterTotalCpuMHz = ($cluster | Get-View).Summary.TotalCpu
        $ClusterCpuLimitMHz = ($cluster | Get-ResourcePool "Resources").CpuLimitMHz
        " " | Out-File -FilePath $Logfile -Append
        $Body0 = "Cluster: $cluster Limit(MHz): $ClusterCpuLimitMHz Total(MHz): $ClusterTotalCpuMHz PoolSum(MHz): $CPULimitSum"
        $Body0 | Out-File -FilePath $Logfile -Append
        $Body1 = $cluster | Get-ResourcePool | Out-String
        $Body1 | Out-File -FilePath $Logfile -Append

        $CpuRessourceAllocation = [math]::Round($CPULimitSum / $ClusterCpuLimitMHz * 100)
        $Body2 = "==> Cluster CPU Ressource allocation is at $CpuRessourceAllocation %" 
        $Body2 | Out-File -FilePath $Logfile -Append
        # Send a Mail Alert when CPU Limit has reached the Alarm Level (90% of available Cluster Ressources) and Alert is new
        if (($CpuRessourceAllocation -ge $AlertLevel) -and !(Test-Path $LogPath$AlertFile)){
            $Subject = "---------- Warning! Pool CPU Limit has reached $CpuRessourceAllocation % of Cluster CPU Limit -------"
            $Subject | Out-File -FilePath $Logfile -Append
            $Body = "$BodyText `n `n  $Body0 `n $Body1 `n $Body2"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
            "=== Alert has been sent $Date ===" | Out-File $LogPath$AlertFile
        }
        "****** End Cluster: $cluster" | Out-File -FilePath $Logfile -Append
        " " | Out-File -FilePath $Logfile -Append
    }
}
Disconnect-VIServer -Server $VIServer -Confirm:$False