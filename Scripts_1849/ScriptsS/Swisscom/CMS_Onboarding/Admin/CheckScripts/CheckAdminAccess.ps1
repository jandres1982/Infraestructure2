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
[string]$Area 				= 'OS/System'

#Short Descripton of the Script
[string]$ShortDescription 	= 'Check local Administrators Group permissions'

#Detaildescripton of the Script
[string]$DetailDescription 	= 'Check if the Administrators Group is member of: Access this computer from the network, Allow log on locally, Allow log on through Terminal Services'
 
#Products
[array]$products 			= 'Full', 'Limited'

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
& '.\CheckScripts\Tools\Carbon\Import-Carbon.ps1'
Import-Module -Name .\Checkscripts\Tools\Carbon\Carbon
 
$GroupToCheck = 'Administrators'
$PrivilegeAllowArr = 'SeNetworkLogonRight', 'SeInteractiveLogonRight', 'SeRemoteInteractiveLogonRight'
$PrivilegeDenyArr = 'SeDenyNetworkLogonRight', 'SeDenyInteractiveLogonRight', 'SeDenyRemoteInteractiveLogonRight'
$ResultAllowArr = @()
$ResultDenyArr = @()
 
$sberror = $null
$sberror = New-Object -TypeName System.Text.StringBuilder
# $sberror.Clear() | out-Null
$sberror.Append("<table class=`"errortable`">")
$sberror.Append('<thead><tr><th>Privilege</th><th>Checked Identity</th><th>Expected Result</th><th>Is Member?</th></tr></thead><tbody>')

 
foreach ($i in $PrivilegeAllowArr)
{
    $TestResult = (Test-Privilege -Identity $GroupToCheck -Privilege $i)
    $sberror.Append("<tr><td>$i</td><td>$GroupToCheck</td><td>True</td><td>$TestResult</td></tr>")
    $ResultAllowArr += $TestResult
}
 
foreach ($d in $PrivilegeDenyArr)
{
    $TestResult = (Test-Privilege -Identity $GroupToCheck -Privilege $d)
    $sberror.Append("<tr><td>$d</td><td>$GroupToCheck</td><td>False</td><td>$TestResult</td></tr>")
    $ResultDenyArr += $TestResult
}
 
if (($ResultAllowArr -contains $false) -or ($ResultDenyArr -contains $true))
{
    $Script:State = $false
    $sberror.Append('</tbody></table>')
    $Script:ErrorInformation = $sberror.ToString()
}
else
{
    $Script:State = $true
    $sberror.Append('</tbody></table>')
    $Script:Information = $sberror.ToString()
}
	
#endregion
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
# ########################## Push the result to the masterScript ############################ 
#region Push result
WriteCheckElement -State $State -Info $Information -error $ErrorInformation -Area $Area -ShortDesc $ShortDescription -Desc $DetailDescription -CheckID $CheckID
#endregion  