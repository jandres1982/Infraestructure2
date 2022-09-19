
function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "SA-PF01-vCSchiRO@itoper.local"
$Path = "D:\Scripts\Schindler\Vmware\VMtools_Restart_Hanging\SCS\"
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
}


################################################################################################
# Connect to vCenterSHHDR
Add-PSSnapin -Name VMware*
$VIServer = "vcenterscs.global.schindler.com"
$Credentials = Get-VCCredential
Connect-VIServer -Server $VIServer -Credential $Credentials



#Get View of all "poweredon" "Windows Server" VMs in Datacenter "SCS" that are on Tools Version "10240" and "Tools are NOT running".
$vmviews = (get-view -ViewType Virtualmachine | Where-Object {$_.runtime.PowerState -like "poweredOn" -and $_.config.tools.toolsVersion -like "10240"-and $_.Guest.ToolsStatus -like "toolsNotRunning"-and $_.config.GuestFullName -like "*Windows Server*"}).name

#Filter out TST* VMs because we need to run with different credentials...
$vms = (get-vm $vmviews | Where-Object {$_.name -notlike "tst*"}).name


################################################################################################
#Write to log file

$Date = Get-date -Format "yyyy-MM-d"
$LogFileName = "$VIServer-$Date.log"
$logfile_path="D:\Scripts\Schindler\Vmware\VMtools_Restart_Hanging\_Logs\$LogFileName"

$vms | Out-File -FilePath $logfile_path -Append

#################################################################################################
#Run the commands for each VM via PSremoting

#Specify which Services shall be touched with the Script
$service1 = "vmvss"
$service2 = "VMtools"
 
Foreach ($vm in $vms) 
{   
Invoke-Command -computer $vm -ScriptBlock {
       Get-Service $using:service1 | Stop-Service -Force -ErrorAction SilentlyContinue
       Get-Service $using:service2 | Restart-Service -Force -ErrorAction SilentlyContinue
       Start-Sleep 10
       $status2 = (get-Service $using:service2).status
       if ($status2 -notlike "Running") {
           Start-Sleep 10
           Start-Service $using:service2 -ErrorAction SilentlyContinue
           }
       $status2new = (get-Service $using:service2).status
       Write-Host "$using:vm - $using:service2 - $status2new" 
       }
} 
#################################################################################################