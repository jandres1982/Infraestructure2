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
        # ScriptName:   CheckWUServicePolicy.ps1
        # Description:  Check WSUS Policy settings
        # Created by:   x86 & Cloud Automatisation | Matthias Fankhauser | matthias.fakhauser@swisscom.com
        # CreateDate:   18.1.2016
        #
        # History:
        # Version 1.0   |   18.1.2016 | Matthias Fankhauser | First version
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
[string]$Area 				= 'Patching'

#Short Descripton of the Script
[string]$ShortDescription 	= 'Check Automatic Updates' 

#Detaildescripton of the Script
[string]$DetailDescription 	= 'Check WSUS Policies via GPO ' 
 
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
 
########################## Script Paramenter ############################

#region Script specific parameters
$sb = New-Object -TypeName System.Text.StringBuilder      # Create stringbuilder object...
$null = $sb.Clear # Clear stringbuilder object
$Error.Clear # Clean up current errorcode

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
$Script:WuServer = $null
$wsusPattern = 'cloudservice.swisscom.com'
 
try
{
    $Script:WuServer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Computer).OpenSubKey('SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\').GetValue('WuServer')
}
catch
{
    $Script:WuServer = 'NoKey'
}

if(($Script:WuServer -eq 'NoKey') -or ($Script:WuServer -eq $null))
{
    $Script:State = $true
    $Script:Information = 'No Policies has been set, Server is ready for Onboarding'
    $Script:ErrorInformation = ' --- '
}
else
{
    if($Script:WuServer -match $wsusPattern)
    {
        $Script:State = $true
        $Script:Information = "<p>Windows Update Server has been configured to BlueNet and is ready for onboarding</br>Server is configured to: $Script:WuServer</p>"
        $Script:ErrorInformation = ' --- '
    }
    else
    {
        $Script:State = $false
        $Script:ErrorInformation = "<p>GPO is configured to a different Windows Update Server.</br>Please move this Server to the defined OU for Onboarding.</br>Actual configured Server: $Script:WuServer</p>"
        $Script:Information = ' --- '
    }
}
#endregion
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
# ########################## Push the result to the masterScript ############################ 
#region Push result
WriteCheckElement -State $State -Info $Information -error $ErrorInformation -Area $Area -ShortDesc $ShortDescription -Desc $DetailDescription -CheckID $CheckID
#endregion  