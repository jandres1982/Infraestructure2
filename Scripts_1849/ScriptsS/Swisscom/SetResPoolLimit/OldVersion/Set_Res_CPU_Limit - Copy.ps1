﻿#===================================================================================#
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
    #$HTactive = $ESXHost.HyperthreadingActive
    $HTactive = $False # Test without Hyperthreading calculation
    if ($HTactive -eq $True) {$HT=2}
    else {$HT=1}
    
    $CPUMhzCore = ($ESXHost.CpuTotalMhz / $ESXHost.NumCpu)
    [long]$CpuLimitMHz = ($CPUcount * $CPUMhzCore / $Ratio / $HT) + $BaseLimit


    #the foolowing information is for test purpose and could be written to a log file instead
    "ResPoolName:  $ResPoolName" | Out-File -FilePath $logfile_path -Append
    "CPU Ratio:    $Ratio" | Out-File -FilePath $logfile_path -Append
    "CPU Count:    $cpucount" | Out-File -FilePath $logfile_path -Append
    "CPU MhzCore:  $CPUMhzCore" | Out-File -FilePath $logfile_path -Append
    "HT Active:    $HTactive" | Out-File -FilePath $logfile_path -Append
    "CPU Limit Mhz:$CpuLimitMHz" | Out-File -FilePath $logfile_path -Append
    "BaseLimit Mhz:$BaseLimit" | Out-File -FilePath $logfile_path -Append 
    " "
    


    #set CPU pool Limit to calculated Limit
    Set-ResourcePool -ResourcePool $ResPoolName -CpuLimitMhz $CpuLimitMHz
}
else{
    "ResPoolName:  $ResPoolName has no powered-on VM's" | Out-File -FilePath $logfile_path -Append
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
$To = "VirtualPlatform.SPOC@swisscom.com", "scc.support@ch.schindler.com", "Erich.Niffeler@swisscom.com"
$ResPoolStartWith = "RP_SCH-*"
$Date = Get-date -Format "yyyy-MM-d"
$LogFileName = "SetCPULimits-$Date.log"
$logfile_path="D:\Scripts\Swisscom\SetResPoolLimit\$LogFileName"
$ValidateSet = @(1,2,4) # Allowed Ratios
$AlertLevel = 0.9 # Level when CPU Limit is 90% of available CPU in Mhz
$Clusters = Get-Cluster


Foreach ($Cluster in $Clusters){
    $Logging = $false
    $CPULimitSum = 0
    $ResourcePools = $cluster | Get-ResourcePool -Name $ResPoolStartWith  # Ressource Pool Name starts with
    $Date=Get-Date
    if ($ResourcePools -ne $null){
        "****** Cluster: $cluster $Date" | Out-File -FilePath $logfile_path -Append
        " " | Out-File -FilePath $logfile_path -Append
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
        " " | Out-File -FilePath $logfile_path -Append
        $Body0 = "Cluster: $cluster Limit(MHz): $ClusterCpuLimitMHz Total(MHz): $ClusterTotalCpuMHz PoolSum(MHz): $CPULimitSum"
        $Body0 | Out-File -FilePath $logfile_path -Append
        $Body1 = $cluster | Get-ResourcePool | Out-String
        $Body1 | Out-File -FilePath $logfile_path -Append

        # Send a Mail Alert when CPU Limit has reached the Alarm Level (90% of available Cluster Ressources)
        if ($CPULimitSum -ge ($AlertLevel * $ClusterCpuLimitMHz)){
            $Subject = "---------- Warning! Pool CPU Limit has reached 90% of Cluster CPU Limit -------"
            $Subject | Out-File -FilePath $logfile_path -Append
            $Body = "$BodyText `n $Body0 `n `n $Body1"
            Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
        }
        "****** End Cluster: $cluster" | Out-File -FilePath $logfile_path -Append
    }
}
Disconnect-VIServer -Server $VIServer -Confirm:$False