# 
# WSUS Management Script
#
# Requirements: PSWindowsUpdate Module
#               See: https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/
#
# Description:  This script can be started by a scheduled Task with global admin credentials. 
#               
# Parameters:   The Script can be started with the following parameters:
#               <arg1>: TargetGroup to be processed
#               <arg2>: Mode (auto or manual) 
#

# Install Windows Featrue Update Services id not already installed
If ((Get-WindowsFeature -Name "UpdateServices-API").installed -eq $false) {Install-WindowsFeature -Name UpdateServices-API}

# Declaration
$LogPath = "H:\WSUS_Scripts\"
$LogFile = "WSUSPatchScript.log"
$Log = "$LogPath$LogFile"
$WSUS_URL = 'shhscpwsusinternal.global.schindler.com'
$WSUS_Port = '8530'
$PWFile = "\\shhwsr0239\C$\inetpub\wwwroot\PWActive.txt"
#$WSUS = Get-WsusServer -Name $WSUS_URL -PortNumber $WSUS_Port

#'tstshhwsr0053' | Out-File "C:\inetpub\wwwroot\PWActive.txt" -Append
#$Entry = 'SHHWSR0055'
#Get-Content $PWFile
#$Liste = Get-Content $PWFile | Where {$_ -ne $Entry}
#$Entry | Out-File $PWFile -Append
#schtasks.exe /run /s <server name> /tn "<scheduled task name>"
#schtasks.exe /run /s <server name> /tn "SCS_SRV_PSWindowsUpdate"
#

function Add-EntryToPWFile(){
<#
.SYNOPSIS
Function to add an Entry to the PatchWindow File
.DESCRIPTION
The PWFile is used by the client to check if the Patch Window is open. The Scripts adds a TargetGroup Name or a Computername to the
the Patch Window File which is located in the WSUS wwwroot directory.  
.PARAMETER Object
The Objects(s) which have to be added to the PWFile
.PARAMETER Objectlist
The Filepath to the objectlist which has to be added to the PWFile
.EXAMPLE
.\Add-EntryToPWFile -Object SHHWSR0117,shhwsr0115 -Path "\\shhwsr0239\C$\inetpub\wwwroot\PWActive.txt"
.\Add-EntryToPWFile -Objectlist c:\temp\Compliste.txt -Path "\\shhwsr0239\C$\inetpub\wwwroot\PWActive.txt"
#>

[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ParameterSetName='Object',
                HelpMessage="Computername(s) or TargetGroup(s) to add to PWList file")]
     [Alias('obj')]
     [String[]]$Object,
     [String[]]$Path,

     [Parameter(Mandatory=$True,
                ParameterSetName='Objectlist',
                HelpMessage="File list of Computername(s) or TargetGroup(s) to add to PWList file")]
     [Alias('filepath')]
     [String[]]$Objectlist
)

# Get Objects
if ($Objectlist -ne $null){
  $Object = Get-Content $Objectlist 
}

# Add Objects to the List
$Object | Out-File "$Path" -Append
}

function Remove-EntryToPWFile(){
<#
.SYNOPSIS
Function to remove Entry(s) from the PatchWindow File
.DESCRIPTION
The PWFile is used by the client to check if the Patch Window is open. The Scripts removes a TargetGroup Name or a Computername to the
the Patch Window File which is located in the WSUS wwwroot directory.  
.PARAMETER Object
The Object(s) which have to be removed from the PWFile
.PARAMETER Objectlist
The Filepath of the objectlist which have to be removed from the PWFile
.EXAMPLE
.\Remove-EntryToPWFile -Object SHHWSR0117,shhwsr0115 -Path "\\shhwsr0239\C$\inetpub\wwwroot\PWActive.txt" 
.\Remove-EntryToPWFile -Objectlist c:\temp\Compliste.txt -Path "\\shhwsr0239\C$\inetpub\wwwroot\PWActive.txt"
#>

[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ParameterSetName='Object',
                HelpMessage="Computername(s) or TargetGroup(s) to add to PWList file")]
     [Alias('obj')]
     [String[]]$Object,
     [String[]]$Path,

     [Parameter(Mandatory=$True,
                ParameterSetName='Objectlist',
                HelpMessage="File list of Computername(s) or TargetGroup(s) to add to PWList file")]
     [Alias('filepath')]
     [String[]]$Objectlist

)

# Get Objects
if ($Objectlist -ne $null){
  $Object = Get-Content $Objectlist 
}
$NewList = Get-Content $Path
# Add Objects to the List
Foreach ($obj in $Object){
  $NewList = $NewList | Where {$_ -ne $Obj}
}
# Update PWFile
$NewList | Out-File "$Path"
}

function Set-TargetGroup(){
<#
.SYNOPSIS
Function to set Target group in the registry of a remote computer
.DESCRIPTION
The WSUS Target Group is stored in the registry in the followin location:
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate  
.PARAMETER Computername
The remote Computer name where the Registry should be changed
.PARAMETER TargetGroup
The TargetGroup Name which will be set to the WSUS registry of the remote computer
.EXAMPLE
.\Set-TargetGroup -Computer SHHWSR0117 -Target
.
#>

[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ParameterSetName='Computername',
                HelpMessage="Computername")]
     [Alias('obj')]
     [String]$Computer,

     [Parameter(Mandatory=$True,
                Position=2,
                ParameterSetName='Computername',
                HelpMessage="TargetGroupname")]
     [String]$TargetGroup
    
)

$Keypath1 = "SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate"  
#SYSTEM\\CurrentControlSet\\services\\LanmanServer\\Parameters"

# Set Server Description to server registry 
$w32reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Computer)
$SubKeys = $w32reg.OpenSubKey($Keypath1,$true)
$value = $SubKeys.GetValue('TargetGroup')
#If value not set already correct it"
if ($value -ne $TargetGroup){
    $SubKeys.SetValue('TargetGroup',"$TargetGroup",[Microsoft.Win32.RegistryValueKind]::String)
    "Computer: $Computer Change Target group old:$Value New: $TargetGroup" | Out-File $Log -Append
}
}

function Get-WSUSStatusReport(){
<#
.SYNOPSIS
Function to set Target group in the registry of a remote computer
.DESCRIPTION
The WSUS Target Group is stored in the registry in the followin location:
HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate  
.PARAMETER $URL
The URL of the WSUS Server
.PARAMETER $Port
The Port used to connect to the WSUS Server (8530 or 8531)
.RETURN $Report 
List of Servers Registered in WSUS
.EXAMPLE
.\Get-WSUSStatusReport -URL 'shhscpwsusinternal.global.schindler.com' -Port '8530'
.
#>

[cmdletBinding()]
param(
     [Parameter(Mandatory=$True,
                Position=1,
                ParameterSetName='WSUS',
                HelpMessage="WSUS URL")]
     [Alias('obj')]
     [String]$URL,

     [Parameter(Mandatory=$True,
                Position=2,
                ParameterSetName='WSUS',
                HelpMessage="WSUS Port number")]
     [String]$Port
    
)
$WSUS = Get-WsusServer -Name $WSUS_URL -PortNumber $WSUS_Port
$computerscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$updatescope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
$Report = $wsus.GetSummariesPerComputerTarget($updatescope,$computerscope) | Select-Object @{L=’ComputerTarget’;E={($wsus.GetComputerTarget([guid]$_.ComputerTargetId)).FullDomainName}},@{L=’TargetGroup’;E={($wsus.GetComputerTarget([guid]$_.ComputerTargetId)).RequestedTargetGroupName}},@{L=’NeededCount’;E={($_.DownloadedCount + $_.NotInstalledCount)}},DownloadedCount,NotApplicableCount,NotInstalledCount,InstalledCount,FailedCount,InstalledPendingRebootCount
Return $Report
}




