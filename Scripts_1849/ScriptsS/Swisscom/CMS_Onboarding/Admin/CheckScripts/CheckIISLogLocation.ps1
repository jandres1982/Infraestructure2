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
# ######################################################################
#>
param
(
    [Parameter(Mandatory    =   $false)][bool]$Collectinfo = $false                 	# Parameter to collect Scriptinformations   
)

$ScriptVersion = "1.0"      # Version
# #################################### General !!! Do not change !!!##############################
#region General definitions
$CScriptRootFolder     =   split-path -parent $MyInvocation.MyCommand.Definition       	# Script RootFolder
$CScriptNameFull       =   $MyInvocation.MyCommand.Definition                          	# Full path of this script including scriptname
$CScriptName           =   [IO.Path]::GetFileNameWithoutExtension($CScriptNameFull)   	# Only the scriptname without extention
$ThisComputername       =   $env:COMPUTERNAME                                           # This computername
$ThisDomain             =   $env:USERDNSDOMAIN                                          # This domain
$ThisServerFQDN         =   $ThisComputername.ToUpper()                                 # Build FQDN string
If(!($ThisDomain -eq $null))
{
    $ThisServerFQDN     = $ThisComputername + '.' + $ThisDomain
}

# Current username that run this script
$DateTimestamp          =   Get-Date -Format "dd.MM.yyyy HH:mm:ss"                    	# Current date and time
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
[string]$Area 				= "App-ISS"

#Short Descripton of the Script
[string]$ShortDescription 	= "Check IIS Log Location" 

#Detaildescripton of the Script
[string]$DetailDescription 	= "Check if IIS Log Location is not configured to System Drive" 
 
#Products
[array]$products 			= "Full", "Limited"

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
[string]$Script:Information 		= ""			#Additional information
[string]$Script:ErrorInformation 	= ""			#ErrorInformation

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
$null = [void]$sb.Clear # Clear stringbuilder object
[void]$Error.Clear # Clean up current errorcode

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
 
 $OsVersionString = (Get-WmiObject -Class Win32_OperatingSystem).Version
 $sberror = new-object System.Text.StringBuilder
 $null = $sberror.Clear
 
 
 Import-Module servermanager
 $IISInstalled = (Get-WindowsFeature | Where-Object {$_.Name -eq "Web-Server"}).Installed
 
 # OS Version Above Windows Server 2008 R2
  if (($IISInstalled -eq "True") -and ($OsVersionString -ne "6.1.7601")){
	 Import-Module WebAdministration
	 $WebSiteArr = (Get-Website).Name
	 $siteDefaults = (Get-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory).Value
	 [void]$sberror.Append("<tr><td>SiteDefaults</td><td>$siteDefaults</td></tr>")
	 $ResultArr = @()
	 
     foreach ($i in $WebSiteArr) {
	 	$SiteLogLocation = (Get-ItemProperty "IIS:\Sites\$i" -name logfile.directory).Value
		[void]$sberror.Append("<tr><td>$i</td><td>$SiteLogLocation</td></tr>")
		if ($SiteLogLocation.StartsWith("C:") -or $SiteLogLocation.StartsWith("%SystemDrive%")) {
			$ResultArr += "False"
		}
	}
	if ($ResultArr -contains $false){
		$Script:State = $false
        [void]$sberror.Append("</tbody></table>")
		$Script:ErrorInformation = $sberror.ToString()
        $Script:Information = ' --- '
	}
    else{
        $Script:State = $true
	    $Script:Information = "The Log File is not configured on System Drive"
        $Script:ErrorInformation = ' --- '
	}
 }
 If ($IISInstalled -eq $false) {
	$Script:State = $true
	$Script:Information = "IIS is not installed!"
    $Script:ErrorInformation = ' --- '
 }


# OS Version Windows Server 2008 R2
  if (($IISInstalled -eq "True") -and ($OsVersionString -eq "6.1.7601")){
	 Import-Module WebAdministration
	 $LogDirectoryC = Get-Content C:\Windows\System32\inetsrv\config\applicationHost.config | select-String -Pattern "<logFile" | select-string -pattern directory | select-String -Pattern "c:"
     $LogDirectorySystemDrive = Get-Content C:\Windows\System32\inetsrv\config\applicationHost.config | select-String -Pattern "<logFile" | select-string -pattern directory | select-String -Pattern "SystemDrive"
     if ((!$LogDirectoryC) -and (!$LogDirectorySystemDrive)) { 
     # Write-host -foreground yellow The Log File is not configured on System Drive
     $Script:State = $true
	 $Script:Information = "The Log File is not configured on System Drive"
     $Script:ErrorInformation = ' --- '
	}
     
    else{
        $LogsInSystem = @($LogsInSystem) +$LogDirectoryC
        $LogsInSystem = @($LogsInSystem) +$LogDirectorySystemDrive
        $Script:State = $false
        $Script:Information = ' --- '
        $null = $sb.AppendLine("<table class=`"errortable`">")
        $null = $sb.AppendLine('<thead><tr><th>Loclocation:</th><th>Value:</th></tr></thead>')
        $null = $sb.AppendLine('<tbody>')
        $null = $sb.AppendLine("<tr><td>Name:</td><td>$LogsInSystem</td></tr>")

        $Script:ErrorInformation = $sb.ToString()
        [void]$sberror.Append("</tbody></table>")
        [void]$sberror.Append("<tr><td>$LogsInSystem</td><td>$LogsInSystem</td></tr>")
        
        
		[void]$sberror.Append("<tr><td>$i</td><td>$LogsInSystem</td></tr>")
		$Script:ErrorInformation = $sberror.ToString()
	}
 }
 

 
 #endregion
 # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
# ########################## Push the result to the masterScript ############################ 
#region Push result
WriteCheckElement -State $State -Info $Information -error $ErrorInformation -Area $Area -ShortDesc $ShortDescription -Desc $DetailDescription -CheckID $CheckID
#endregion  
  
  
  