#requires -Version 2
<#
        .SYNOPSIS
        Checkscript for a specific test.
        .DESCRIPTION
        This script is based on the MasterCheck.ps1 script.
        The script take a specific check which is definied, and write the result back to the MasterCheck script.

        The following function can be used from the Masterscript MasterCheck.ps1:
        LogWriter (Write in the specified Logfile of the MasterCheck.ps1 script)
        WriteCheckElement (writes the result of this check to the Result file which is defined in the MasterCheck.ps1 script)
                       
        .EXAMPLE
        Functions which are used from MasterCheck...
        LogWriter "my input for the Logfile..." (Add entry with timestamp...)
        LogWriter "my input for the Logfile..." 0 (without timestamp for headers etc...)
        WriteCheckElement -State $true -Info "No more Infomation." -error "Information about the Error if exists." -Area "OS" -ShortDesc "Example" -Desc "Description for the example" -CheckID ChecksciptTemplate

        .NOTES
        Information about the type of the parameters in WriteCheckElement:

        -[boolean]State     ($true | $false)
        If the check is passed then $true else $false (writes additional infos below the error message)
  
        -[string]Info
        Information to the check (optional)
  
        -[string]error
        Important information when the check failed.
        example: -error "<h2>this is the error</h2><ul><li>item 1</li><li>item 2</li><li>item 3</li></ul>"
  
        -[string]Area  
        Defined the area of the checkScript

        -[string]ShortDesc
        Short description of the check    
 
        -[string]Desc
        Detaildescription about the script
 
        -CheckID
        This ist the name of the script and unique
 
        # ######################################################################
        # ScriptName:   CheckTemplate.ps1
        # Description:  Template for SystemChecks
        # Created by:   x86 & Cloud Automatisation | Matthias Fankhauser | matthias.fakhauser@swisscom.com
        # CreateDate:   16.09.2015
        #
        # History:
        # Version 1.0   |   16.09.2015 | Matthias Fankhauser | First version
        # Version 1.1   |   18.01.2016 | Matthias Fankhauser | Review
        # ######################################################################
#>
param
(
    [Parameter(Mandatory    = $false)][bool]$Collectinfo = $false                 	# Parameter to collect Scriptinformations   
)

$ScriptVersion = '1.1'      # Version
# #################################### General !!! Do not change !!!##############################
#region General definitions
$CScriptRootFolder     = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition       	# Script RootFolder
$CScriptNameFull       = $MyInvocation.MyCommand.Definition                          	# Full path of this script including scriptname
$CScriptName           = [IO.Path]::GetFileNameWithoutExtension($CScriptNameFull)   	# Only the scriptname without extention
$ThisComputername       = $env:COMPUTERNAME                                           # This computername
$ThisDomain             = $env:USERDNSDOMAIN                                          # This domain
$ThisServerFQDN         = $ThisComputername.ToUpper()                                 # Build FQDN string
If(!($ThisDomain -eq $null))
{
    $ThisServerFQDN     = $ThisComputername + '.' + $ThisDomain
}

# Current username that run this script
$DateTimestamp          = Get-Date -Format 'dd.MM.yyyy HH:mm:ss'                    	# Current date and time
# OS description (name)
#endregion
# ######################################################################

# ----------------------------------------------------------------------------------------------------- 
# ########################## Script Paramenter (Costumized for each script)############################
#region Header Informations
# This items are to define based on the Excelsheet with the Checks.

#CheckArea (Where is this check required)
[bool]$PreCheck 			= $true
[bool]$QCheck 				= $true

#Area
[string]$Area 				= 'OS/System/Server Hardening'

#Short Descripton of the Script
[string]$ShortDescription 	= 'Checks if Server Hardening has been applied' 

#Detaildescripton of the Script
[string]$DetailDescription 	= 'Server Hardening, Checks if Windows Services which are not required are Configured to be ""Disabled""' 
 
#Products
[array]$products 			= 'Full' , 'Limited'

#endregion
# ######################################################################
# -----------------------------------------------------------------------------------------------------
 
# ####################### Functions ##########################
#region Functions of the Masterscript !!! Must be on Top of this Script !!!
# #################################################

# Collect informations about this script
function PutScriptInfo ()
{
    CollectScriptInfo -Area $Area -CheckScriptFullPath  $CScriptNameFull -CheckID $CScriptName -products $products -PreCheck $PreCheck -QCheck $QCheck
}
#endregion
# #################################################
 

# ########################## Script static Paramenters !!! Do not change !!! ############################
#region Script static Paramenters
[string]$CheckID			= $CScriptName	# CheckID is the Scriptname
[bool]	$Script:State 				= $false		#State Check
[string]$Script:Information 		= ''			#Additional information
[string]$Script:ErrorInformation 	= ''			#ErrorInformation

# Run only when the argument -Collectinfo is true --> exit
if($Collectinfo)
{
    PutScriptInfo
    exit
}
#endregion
# #######################################################################################################
 
# ########################## Script Paramenter ############################

#region Script specific parameters
$sb = New-Object -TypeName System.Text.StringBuilder      # Create stringbuilder object...
$null = $sb.Clear # Clear stringbuilder object

# ######################################################################### 

 
# ####################################################################################################### 
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++ Here is the section for the Check ++++++++++++++
#
# Required Output of this Script:
# 
# $Script:State = $true | $false (Is the Check OK or not OK)
# $Script:Information = "...." (Aditional Information about the result)
# $Script:ErrorInformation = "Information about non passed check"
#
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
#region checkscript

$W2k8UnnecessaryService	= 'AudioEndpointBuilder', 'Audiosrv', 'Browser', 'FontCache', 'iphlpsvc', 'NetTcpPortSharing', 'RemoteAccess', 'SCardSvr', 'seclogon', 'SharedAccess', 'ShellHWDetection', 'SSDPSRV', 'TrkWks', 'upnphost', 'WcsPlugInService' 
$UnnecessaryService 	= 'AudioEndpointBuilder', 'Audiosrv', 'Browser', 'FontCache', 'iphlpsvc', 'NcaSvc', 'NetTcpPortSharing', 'RemoteAccess', 'SCardSvr', 'seclogon', 'SharedAccess', 'ShellHWDetection', 'SSDPSRV', 'Themes', 'TrkWks', 'upnphost', 'WcsPlugInService'
$DesiredServiceState 	= 'Disabled'
$ResultArr 				= @()

if ((Get-WmiObject -Class Win32_OperatingSystem).Version -eq '6.1.7601')
{
    $UnnecessaryService = 'AudioEndpointBuilder', 'Audiosrv', 'Browser', 'FontCache', 'iphlpsvc', 'NetTcpPortSharing', 'RemoteAccess', 'SCardSvr', 'seclogon', 'SharedAccess', 'ShellHWDetection', 'SSDPSRV', 'TrkWks', 'upnphost', 'WcsPlugInService'
}

$sberror = New-Object -TypeName System.Text.StringBuilder
$null = $sberror.Clear
$sberror.Append("<table class=`"errortable`">")
$sberror.Append('<thead><tr><th>Windows Service Display Name</th><th>Service Name</th><th>Expected Result</th><th>Current Configuration</th></tr></thead><tbody>')
 
foreach ($i in $UnnecessaryService) 
{
    $ServiceDisplayName	= (Get-WmiObject -Class win32_service | Where-Object -FilterScript {
            ($_.name -eq $i)
    }).displayname
    $ServiceStartMode 	= (Get-WmiObject -Class win32_service | Where-Object -FilterScript {
            ($_.name -eq $i)
    }).startmode
    if ($ServiceStartMode)
    {
        $sberror.Append("<tr><td>$ServiceDisplayName</td><td>$i</td><td>$DesiredServiceState</td><td>$ServiceStartMode</td></tr>")
        $ResultArr += $ServiceStartMode
    }
    else 
    {
        $sberror.Append("<tr><td>$i</td><td>$DesiredServiceState</td><td>Service not found!</td></tr>")
    }
}

if ($ResultArr -ne 'Disabled')
{
    $Script:State = $false
    $sberror.Append('</tbody></table>')
    $sberror.Append('Not all services are disabled!')
    $Script:ErrorInformation = $sberror.ToString()
}
else 
{
    $Script:State = $true
    $sberror.Append('</tbody></table></br>')
    $sberror.Append('All unnecessary services are disabled!')
    $Script:Information = $sberror.ToString()
}
 
#endregion
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
# ########################## Push the result to the masterScript ############################ 
#region Push result
WriteCheckElement -State $State -Info $Information -error $ErrorInformation -Area $Area -ShortDesc $ShortDescription -Desc $DetailDescription -CheckID $CheckID
#endregion  
  