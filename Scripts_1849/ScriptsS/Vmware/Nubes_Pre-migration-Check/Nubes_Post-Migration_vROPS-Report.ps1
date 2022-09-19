
#######################################################
<#
        .SYNOPSIS
        Create a request file for vROPs
        
		.DESCRIPTION
        Creates a request file for VMs migrated last hour which will be picked up
        by another script on ss001000 to generate a vRops Report
        
		.PARAMETER abc
		param description

		.PARAMETER xyz
		param description
		
        .EXAMPLE
                

        .NOTES
        Information about the type of the parameters:
                             
        # ######################################################################
        # ScriptName:   .ps1
        # Description:  Create a request file for vROPs
        # Created by:   Michael Barmettler
        # CreateDate:   06.08.2017
        #
        # History:
        # Version 0.1 | 06.08.2017 | Michael Barmettler | First draft version
        # ######################################################################
#>

# #################################### General ##############################
#region General definitions

#$ScriptRootFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptRootFolder = "D:\Scripts\Schindler\Vmware\Nubes_Pre-migration-Check\"   #use only when run in ISE

#$ScriptNameFull = $MyInvocation.MyCommand.Definition
#$ScriptName = [IO.Path]::GetFileNameWithoutExtension($ScriptNameFull)
$CurrentUser = $env:USERNAME
$DateTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DateLog = Get-Date -Format 'yyyyMMdd'
#endregion General definitions
# ######################################################################

# #################################### Modules ##############################
#region Import Modules

#We need to force the logging module load here, because the argument list has to be set
#Do no force to load the logging module if you are using it within a module!

<#Import-module -name Logger -ArgumentList "D:\Logs","$($ScriptName)_$($DateLog).txt" -Force
Add-LogEntry -logstring "Loaded Logging module"
#>

# Loading VMware Modules
<#

#>
Import-Module SQLPS

<#
if (-not (Get-Module -Name "VMware.VimAutomation.Core")) {
    Import-module -name VMware.VimAutomation.Core -Force
    #Add-LogEntry -logstring "Loaded VMware.VimAutomation.Core module"
} else {
    #Add-LogEntry -logstring "VMware.VimAutomation.Core module already loaded"
}

if (-not (Get-Module -Name "VMware.VimAutomation.vROps")) {
    Import-module -name VMware.VimAutomation.vROps -Force
    #Add-LogEntry -logstring "Loaded VMware.VimAutomation.vROps module"
} else {
    #Add-LogEntry -logstring "VMware.VimAutomation.Core module already loaded"
}

<#
if (-not (Get-Module -Name "sc_helper")) {
    Import-module -name sc_helper -Force
    #Add-LogEntry -logstring "Loaded sc_helper module"
} else {
    #Add-LogEntry -logstring "sc_helper module already loaded"
}
#>

#endregion Import Modules
# ######################################################################

# #################################### Variables ##############################
#region Variables
 
# Version
$ScriptVersion = '0.2' 

$Networkshare = '\\sdbdna0002.global.schindler.com\infosrv\Admintools\vROPs\Swisscom\Reports'   # Will map to drive X
$Output = 'X:\Swisscom\Reports\'
#$shareuser = 'admbarmetmi@global.schindler.com'    #Specify the username to connect to the networkshare (PW will be stored in securestring)
$SQLUser = "sa-db-schindlerexport"  #Read only permission
$ServerInstance = "10.10.100.112"
$DB = "MigDB"
$SQLpw = "3d81e118-6859-4d91-8948-f36710de0d91"

#endregion Variables
# ######################################################################

# #################################### Main ##############################
#region Main

function Get-CredentialFile {

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True, Position=1)]
   [string]$username
)

#initialize variables
$AdminName = $env:USERNAME
$Path = "$ScriptRootFolder\Credentials\"
$CredsFile = "$Path$AdminName$username-Creds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
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

<#---------------------------------------------------------------------
PHASE 1: Create PSDrive to Network-Share. Use SecureString DPAPI encryption for Password
----------------------------------------------------------------------#>

#$NASCredentials = Get-CredentialFile -username $shareuser
    try {
        
        New-PSDrive -Name "X" -PSProvider FileSystem -root $Networkshare -ErrorAction Stop #-Credential $NASCredentials
    }
    catch {
        $msg = $_.Exception.Message
        Write-host $msg
        break
    }

# Query the Cloudinator Database to get all VMs with migration date

$SQLquery =@" 
 
select server_name, CONVERT(varchar,lswave_date,104) as lswave_day, CONVERT(varchar,lswave_date,108) as lswave_time, lswave_site, CONVERT(varchar,rhserver_lsend,104) as lsend_day, CONVERT(varchar,rhserver_lsend,108) as lsend_time
 from dbo.rhserver as rhs INNER JOIN server as srv
 ON rhs.rhserver_id = srv.server_id
 INNER JOIN lswave as lsw
 ON rhserver_lswave = lsw.lswave_id
 
"@ 
 
$serverlist = invoke-sqlcmd -query $SQLquery -serverinstance $ServerInstance -database $DB -Username $SQLUser -Password $SQLpw

########################################################
# Filter for only VMs where migration was finished one hour ago

$2hagodate = (Get-Date).AddHours(-2).ToString('dd.MM.yyyy')
$2hagoHH = (Get-Date).AddHours(-2).ToString('HH')
$7hagodate = (Get-Date).AddHours(-7).ToString('dd.MM.yyyy')
$7hagoHH = (Get-Date).AddHours(-7).ToString('HH')
$24hagodate = (Get-Date).AddHours(-24).ToString('dd.MM.yyyy')
$24hagoHH = (Get-Date).AddHours(-24).ToString('HH')
$tomorowdate = (Get-Date).AddDays(+1).ToString('dd.MM.yyyy')


<#
$2hoursagovms = $serverlist | Where-Object {$_.lsend_day -like "$2hagodate"}
foreach ($vm in $2hoursagovms) {
New-Item "x:\CP_T-SCH_VXB-VM-Perf-1h\$($vm.server_name).vm" -ItemType file
}
#>

$7hoursagovms = $serverlist | Where-Object {$_.lsend_day -like "$7hagodate" -and $_.lsend_time -like "$($7hagoHH):*"}
foreach ($vm in $7hoursagovms) {
New-Item "x:\CP_T-SCH_VXB-VM-Perf-6h\$($vm.server_name).vm" -ItemType file
}

Remove-PSDrive -Name "X" -Force