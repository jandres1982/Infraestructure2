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
[string]$ShortDescription 	= 'Check license status of the machine' 

#Detaildescripton of the Script
[string]$DetailDescription 	= 'Check wether the machine is activated or not.' 
 
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
 
# ########################## Script Paramenter ############################

#region Script specific parameters
$sb = New-Object -TypeName System.Text.StringBuilder      # Create stringbuilder object...
$null = $sb.Clear # Clear stringbuilder object
$Error.Clear # Clean up current errorcode

# #########################################################################



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
 
    
try {
    $InstalledLicense = Get-WmiObject -Query "Select * from SoftwareLicensingProduct Where PartialProductKey IS NOT NULL AND ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'"
    Switch ($InstalledLicense.LicenseStatus) {
            0 
            {
                $Script:ErrorInformation = 'Windows is not activated! Unlicensed'
                $Script:Information = ' --- '
                $Script:State = $false
                Write-Host -ForegroundColor Yellow Windows is not activated! Unlicensed
            }
            1 
            {
                $Script:Information = 'Licensed'
                $Script:ErrorInformation = ' --- '
                $Script:State = $true
                Write-Host -ForegroundColor DarkGreen Licensed
            }
            2 
            {
                $Script:ErrorInformation = 'Windows is not activated! Out-Of-Box Grace Period'
                $Script:Information = ' --- '
                $Script:State = $false
                Write-Host -ForegroundColor DarkRed Windows is not activated! Out-Of-Box Grace Period
            }
            3 
            {
                $Script:ErrorInformation = 'Windows is not activated! Out-Of-Tolerance Grace Period'
                $Script:Information = ' --- '
                $Script:State = $false
                Write-Host -ForegroundColor DarkGreen Windows is not activated! Out-Of-Tolerance Grace Period
            }
            4 
            {
                $Script:ErrorInformation = 'Windows is not activated! Non-Genuine Grace Period'
                $Script:Information = ' --- '
                $Script:State = $false
                Write-Host -ForegroundColor Cyan Windows is not activated! Non-Genuine Grace Period
            }
            5 
            {
                $Script:ErrorInformation = 'Windows is not activated! Notification'
                $Script:Information = ' --- '
                $Script:State = $false
                Write-Host -ForegroundColor DarkMagenta Windows is not activated! Notification
            }
            6 
            {
                $Script:ErrorInformation = 'Windows is not activated! Extended Grace'
                $Script:Information = ' --- '
                $Script:State = $false
                Write-Host -ForegroundColor White Windows is not activated! Extended Grace
            }
            default {
                     $Script:ErrorInformation = 'Unknown value'
                     $Script:Information = ' --- '
                     $Script:State = $false
            }
        }

} catch {
    $Script:ErrorInformation = 'Windows is not activated! No SoftwareLicensingProduct with PartialProductKey found!'
    $Script:Information = ' --- '
    $Script:State = $false

}

 
#endregion
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
# ########################## Push the result to the masterScript ############################ 
#region Push result
WriteCheckElement -State $State -Info $Information -error $ErrorInformation -Area $Area -ShortDesc $ShortDescription -Desc $DetailDescription -CheckID $CheckID
#endregion  
  