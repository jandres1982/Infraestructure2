<#
        .SYNOPSIS
        Deploy VM with Guest Customization (inject DSC)
   
        
              .DESCRIPTION
        This Script is intended to deploy a VM from template and inject Guest customization (e.g. DSC config, Computer Description ect)
        

              .PARAMETER abc
              param description

              .PARAMETER xyz
              param description
              
        .EXAMPLE
                

        .NOTES
        Information about the type of the parameters:
                             
        # ######################################################################
        # ScriptName:   Schi-VMDeploy.ps1
        # Description:  Import OVA files based on a trigger (.imp) file
        # Created by:   Michael Barmettler
        # CreateDate:   23.02.2017
        #
        # History:
        # Version 0.1 | 23.02.2017 | Michael Barmettler | First draft version
        # ######################################################################
#> 


[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$servername,

   [Parameter(Mandatory=$True, Position=2)]
   [string]$serverfunction,

   [Parameter(Mandatory=$True, Position=3, HelpMessage="Enter Timezone (100 = CET)")]
   [ValidateLength(1,3)]
   [string]$Timezone
   
)

# #################################### General ##############################
#region General definitions

#$ScriptRootFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
#$ScriptNameFull = $MyInvocation.MyCommand.Definition

$ScriptRootFolder = "D:\Scripts\Swisscom\TSTVmdeploy"                         #use this lines if run in ISE, otherwise use the lines above
$ScriptNameFull = "D:\Scripts\Swisscom\TSTVmdeploy\Schi-VMDeploy.ps1"          #use this lines if run in ISE, otherwise use the lines above

$ScriptName = [IO.Path]::GetFileNameWithoutExtension($ScriptNameFull)
$CurrentUser = $env:USERNAME
$DateTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DateLog = Get-Date -Format 'yyyyMMdd'
#endregion General definitions
# ######################################################################


# #################################### Variables ##############################
#region Variables

# Version
$ScriptVersion = '0.1' 

#$vcname = "vcentershh.global.schindler.com"                                     #vCenter Server
#$vcusername = ""
#$domainfqdn = "tstglobal.schindler.com"
#$adcredentials = Get-Credential -Message "Enter Password to Join Server to $domainfqdn Domain:"

$localadmincreds = Get-Credential -Message "Enter Password for local Administrator for new Server:"

$cluster = ""
$datastore = ""
$sourcetemplate = ""


$DSCServer = '"http://tstzzzwsr9990.tstglobal.schindler.com:8080/PSDSCPullServer.svc"'
$DSCConfigurationNames = '"ServerConfig"'
$DSCReportServer = '"http://tstzzzwsr9990.tstglobal.schindler.com:8080/PSDSCPullServer.svc"'
$DSCRegistrationKey = '"00d71de4-decb-4da3-bb5f-be5674b8ec88"'



function Get-CredentialFile {

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True, Position=1)]
   [string]$username
)

#initialize variables
$AdminName = $env:USERNAME
$Path = "$ScriptRootFolder\Credentials\"
$CredsFile = "$Path$AdminName-Creds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
    $Cred = Get-Credential -Message "Provide Credentials" -UserName $username
    $Cred.Password | ConvertFrom-SecureString | Out-File $CredsFile
}
else
    {Write-Host 'Using your stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password}

sleep 2
Return $cred
} 

<# 
#####################################################################################
# Connect to vCenter
#-------------------
Add-PSSnapin -Name VMware*
$vcname
$Credentials = Get-CredentialFile -username $vcusername

Try {
Connect-VIServer -Server $vcname -Credential $Credentials -ErrorAction Stop
} Catch {
$Body = "Could not connect to vCenter $vcname. Check if $vcname is available and service-account $vcusername is permitted read-only access in this vCenter."
Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body
Write-Error $Body -ErrorAction Stop
}
#>

###################################################
# Define DSC LCM config for the new VM
###################################################

$DSCConfig =
'instance of MSFT_WebDownloadManager as $MSFT_WebDownloadManager1ref{ResourceID = "[ConfigurationRepositoryWeb]DSC-Pull";',
'SourceInfo = "\\\\sdbdna0002.global.schindler.com\\infosrv\\Admintools\\DSC\\Setup_DSC-PullClient.ps1::15::9::ConfigurationRepositoryWeb";',
"RegistrationKey = $DSCRegistrationKey;",
'AllowUnsecureConnection = True;',
"ConfigurationNames = {$DSCConfigurationNames};",
"ServerURL = $DSCServer;};",
'instance of MSFT_WebReportManager as $MSFT_WebReportManager1ref{SourceInfo = "\\\\sdbdna0002.global.schindler.com\\infosrv\\Admintools\\DSC\\Setup_DSC-PullClient.ps1::22::9::ReportServerWeb";',
"ServerURL = $DSCReportServer;'",
'ResourceID = "[ReportServerWeb]DSC-Pull";};',
'instance of MSFT_DSCMetaConfiguration as $MSFT_DSCMetaConfiguration1ref{RefreshMode = "Pull";',
'AllowModuleOverwrite = True;',
'RefreshFrequencyMins = 30;',
'RebootNodeIfNeeded = True;',
'ConfigurationModeFrequencyMins = 15;',
'ConfigurationMode = "ApplyAndAutoCorrect";',
'ReportManagers = {$MSFT_WebReportManager1ref};',
'ConfigurationDownloadManagers = {$MSFT_WebDownloadManager1ref};};'

#####################################################

$RunOnce = (
    "net config server /SRVCOMMENT:`"$serverfunction`"",
    "cmd /c powershell.exe -command `"$($DSCConfig -join ',') | Out-File 'c:\windows\system32\configuration\metaconfig.mof'"
)


New-OSCustomizationSpec -Type NonPersistent -Name "TEST_$servername" -OSType Windows -Description "TEST_$servername" -FullName "Test" -OrgName "Test" -NamingScheme Fixed -NamingPrefix $servername -AdminPassword $localadmincreds.GetNetworkCredential().password -TimeZone $Timezone -ChangeSid -Workgroup WORKGROUP -GuiRunOnce $RunOnce -AutoLogonCount 1

New-VM -Name $servername -ResourcePool $cluster -Datastore $datastore -Template $sourcetemplate -OSCustomizationspec "TEST_$servername"
