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
        # ScriptName:   CheckPatchLevel.ps1
        # Description:  Check patchlevel of this system
        # Created by:   x86 & Cloud Automatisation | Matthias Fankhauser | matthias.fakhauser@swisscom.com
        # CreateDate:   12.01.
        #
        # History:
        # Version 1.0   |   16.09.2015 | Matthias Fankhauser | First version
        # Version 1.1   |   16.09.2015 | Matthias Fankhauser | Fix for InstalledON Token
        # Version 1.2   |   18.01.2016 | Matthias Fankhauser | Review
        # ######################################################################
#>
param
(
    [Parameter(Mandatory    = $false)][bool]$Collectinfo = $false                 	# Parameter to collect Scriptinformations   
)

$ScriptVersion = '1.2'      # Version
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
[string]$ShortDescription 	= 'Check Patch Level of the machine' 

#Detaildescripton of the Script
[string]$DetailDescription 	= 'Check when the last Patch has been applied and if this is within the Supported Time Range' 
 
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

# Defines the  accepted time span for no patching
$PatchThreshold = ((Get-Date).AddDays(-30))
# #############################################

# Initialize Arrays
$Patches = @()
#$latestPatch = @()

# Get curent patches with wmic...
$outputWmic = Invoke-Expression -Command 'wmic QFE LIST' 
$outputWmic = $outputWmic[1..($outputWmic.length)]

# Check ouptput wmic
foreach ($output in $outputWmic) 
{
    if ($output) 
    {
        # CleanUP
        $output = $output -replace 'y U', 'y-U'
        $output = $output -replace 'NT A', 'NT-A'
        $output = $output -replace '\s+', ' '
        $parts = $output -split ' '
        if ($parts[5] -like '*/*/*') 
        {
            $Dateis = [datetime]::ParseExact($parts[5], '%M/%d/yyyy',[Globalization.cultureinfo]::GetCultureInfo('en-US').DateTimeFormat)
        } 
        elseif ($parts[4] -like '*/*/*') 
        {
            $Dateis = [datetime]::ParseExact($parts[4], '%M/%d/yyyy',[Globalization.cultureinfo]::GetCultureInfo('en-US').DateTimeFormat)
        }
        elseif (($parts[5] -eq $null) -or ($parts[5] -eq ''))
        {
            $Dateis = [datetime]1700
        }
        else 
        {
            $Dateis = Get-Date -Date ([DateTime][Convert]::ToInt64("$parts[5]", 16))-Format '%M/%d/yyyy'
        }
            
        If(!($parts[4] -like '*/*/*'))
        {
            $FixPart4 = [string]$parts[4]
        }
        else
        {
            $FixPart4 = ''
        }

        # Create PsObject from PatchItem    
        $null = $PatchItem = New-Object -TypeName PSObject -Property @{
            KBArticle           = [string]$parts[0]
            Computername        = [string]$parts[1]
            Description         = [string]$parts[2]
            FixComments         = [string]$parts[6]
            HotFixID            = [string]$parts[3]
            InstalledOn         = Get-Date -Date ($Dateis)-Format 'yyyy.MM.dd HH:mm:ss'
            InstalledBy         = [string]$FixPart4
            InstallDate         = [string]$parts[7]
            Name                = [string]$parts[8]
            ServicePackInEffect = [string]$parts[9]
            Status              = [string]$parts[10]
        }
    }
    # Add PsObject to PSObject Array
    $Patches += $PatchItem
}
  
# Sort according to InstallDate and select the first One
$latestPatch = $Patches |
Sort-Object -Property InstalledOn -Descending |
Select-Object -First 1

# Count installed updates
$totalPatchesFound = $Patches.Count

# Locate the installdate of Top1
[DateTime]$datelastPatch = $latestPatch.InstalledOn

# Check Patchlevel ist ok or not
If($datelastPatch -ge $PatchThreshold)
{
    $Script:State = $true 
    $Script:Information = '<p>The last Hotfix has to be installed after:' + $PatchThreshold.ToString('dd. MMMM yyyy') + '</p><br><p>Patchlevel OK. Last Installdate is:' + $datelastPatch.ToString('dddd dd.MM.yyyy') + "<br>Total $totalPatchesFound installed Updates found</p>"
    $Script:ErrorInformation = ' --- '
}
else 
{
    $Script:State = $false
    $Script:Information = "<p>Total $totalPatchesFound installed Updates found</p>"

    $datinfo = $PatchThreshold.ToString('dd. MMMM yyyy')
    $Script:ErrorInformation = '<p>The date of the last installed patches, is greater than the defined Date: ' + $PatchThreshold.ToString('dd. MMMM yyyy') + '<br>The last Installdate is: ' + $datelastPatch.ToString('dddd dd.MM.yyyy') + '</p>'
}
 
#endregion
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
# ########################## Push the result to the masterScript ############################ 
#region Push result
WriteCheckElement -State $State -Info $Information -error $ErrorInformation -Area $Area -ShortDesc $ShortDescription -Desc $DetailDescription -CheckID $CheckID
#endregion  