#requires -Version 2
<#
        .SYNOPSIS
        MasterScript for the ServerChecks 
        .DESCRIPTION
        The MasterCheck.ps1 is the basic script for the checks.
        This Script provides the functions for the Check-Scripts to create the output file which contains the results.
        Based on the arguments, the MasterCheck script initiated the Check-Scripts which run on the system to check.
        .PARAMETER CheckTyp
        Parameter with type of the check (PreCheck | QCheck
        .PARAMETER Product
        Parameter with the products (single product or an array with products)
        .OUTPUTS
        Generate an output file
        .EXAMPLE
        ./MasterCheck.ps1 -CheckTyp "QCheck" -Product Full,MSSQL	(this use scripts which are assigned to this product)
        .NOTES
        All Ceckscripts need this script to write to the result file
        # ######################################################################
        # ScriptName:   MasterCheck.ps1
        # Description:  MasterScript for the CheckScripts
        # Created by:   x86 & Cloud Automatisation | Matthias Fankhauser | matthias.fakhauser@swisscom.com
        # CreateDate:   14.09.2015
        #
        # History:
        # Version 0.9   |   14.09.2015 | Matthias Fankhauser | First version
        # Version 1.0	|	18.09.2015 | Matthias Fankhauser | Final version
        # Version 1.1	|	18.09.2015 | Matthias Fankhauser | Fix Table errortable , design
        # Version 1.2   |   06.01.2015 | Matthias Fankhauser | Fixed for PowerShell 2.0
        # Version 1.3   |   18.01.2016 | Matthias Fankhauser | BugFix
        # ######################################################################
#>
# param
param
(
    [Parameter(Mandatory    = $true)][ValidateSet('qcheck','precheck')][string]$CheckType,     # Parameter with the type of the check
    [Parameter(Mandatory    = $true)][Array]$products 	               						# Array with the specific products to Check (!!!Important!!! do not Use ""!!!)
)
$MaScriptVersion = '1.3'      # Version
# #################################### General  !!! Do not change !!! ##############################
#region General definitions
Clear-Host # CleanUP Output
$ScriptRootFolder   = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition     # Script RootFolder
$ScriptNameFull     = $MyInvocation.MyCommand.Definition                        # Full path of this script including scriptname
$ScriptName         = [IO.Path]::GetFileNameWithoutExtension($ScriptNameFull)   # Only the Scriptname without extension
$ThisComputername   = $env:COMPUTERNAME                                         # This Computername
$ThisDomain         = $env:USERDNSDOMAIN                                        # This Domain
$ThisServerFQDN     = $ThisComputername.ToString().ToUpper()                               # Build FQDN String
If(!($ThisDomain -eq $null))
{
    $ThisServerFQDN     = $ThisComputername + '.' + $ThisDomain
}
else
{
    $ThisDomain 		= 'Not member of a Domain'
}
$CurrentUser        = $env:USERNAME                                             # Current username that runs this Script
$DateTimestamp      = Get-Date -Format 'dd.MM.yyyy HH:mm:ss'                  	# Current Date and Time
$DTLogfilename      = Get-Date -Format 'ddMMyyyyHHmmss'                  		# Current Date and Time
$OSVersion          = [string][environment]::OSVersion.Version.Major + '.' + [string][environment]::OSVersion.Version.Minor       # OS-Version
$OSVersionCaption   = (Get-WmiObject -Class Win32_OperatingSystem -Namespace root\CIMV2).caption                                # OS Description (Name)
$PowerShellVersion  = ($PSVersionTable).PSVersion.Major                       	# Get the current Powershell version
$OperatingSystem	= (Get-WmiObject -Class Win32_OperatingSystem).Caption
$CPULogic 			= (Get-WmiObject -Class Win32_Processor).NumberOfLogicalProcessors
$CPUCore 			= (Get-WmiObject -Class Win32_Processor).NumberOfCores
$PhysicalRAM 		= (Get-WmiObject -Class Win32_PhysicalMemory |
    Measure-Object -Property capacity -Sum |
    ForEach-Object -Process {
        [Math]::Round(($_.sum / 1GB),2)
})
$ServerDescription  = (Get-WmiObject -Class Win32_OperatingSystem).Description
#endregion
# ######################################################################

# ########################## Script Paramenter ############################
#region Script specific parameters

$typ = $CheckType.ToString().ToUpper()
$prod = $products -join ' '.ToString().ToUpper()
$RunCounter = 0
$Global:RunCounterFail = 0

$LogFolder          	= 'C:\Admin\Logs'                                                         				# Define the log folder
$ScriptName_Log     	= "$ScriptName.log"                                                    					# Define the name for the logfile
$ScriptLogFull      	= "$LogFolder\$ScriptName_Log"                                            				# Fullpath for the Logfile
$ResultFile      		= "$LogFolder\Report_" + $typ + '_' + $DTLogfilename + '_' + $ThisServerFQDN + '.html'  # Generated html File
$RootRelCheckScripts    = "$ScriptRootFolder\CheckScripts\"                          							# Rootfolder for Checkscripts (Release and OS specific)
$ScriptExtention    	= '.ps1' 
$Tools 					= "$ScriptRootFolder\CheckScripts\Tools\" 

# Create DataTable to collect scriptinformations
$dtScriptinfos = New-Object -TypeName System.Data.dataTable
$dw = New-Object -TypeName System.Data.DataView -ArgumentList ($dtScriptinfos)
$null = $dtScriptinfos.Columns.Add('Area'), [string]
$null = $dtScriptinfos.Columns.Add('CheckID'), [string]
$null = $dtScriptinfos.Columns.Add('ScriptPath', [string])
$null = $dtScriptinfos.Columns.Add('products', [array])
$null = $dtScriptinfos.Columns.Add('PreCheck', [bool])
$null = $dtScriptinfos.Columns.Add('QCheck', [bool])

#Stringbuilder for Report
$sb = New-Object -TypeName System.Text.StringBuilder
$null = $sb.Clear

#Stringbuilder for Report
$sbItem = New-Object -TypeName System.Text.StringBuilder
$null = $sbItem.Clear
#endregion
# #########################################################################

# ####################### Functions ##########################
#region Functions of the Masterscript !!! Must be on Top of this Script !!!
# #################################################

# Function write logfile
function LogWriter #Write Log entrys
{
    Param ([string]$logstring ,[int]$typestamp = 1)  # Parameter for the function
    
    if($typestamp -eq 1)
    {
        $timestamp = (Get-Date).ToString('dd.MM.yyyy HH:mm:ss ')      # Current Date and Timestamp
        Add-Content $ScriptLogFull -Value "$timestamp `t$logstring"   # Write the content
        Write-Host -Object "$timestamp `t$logstring"                  # Output to Console
    }
    else
    {
        Add-Content $ScriptLogFull -Value "`t`t`t$logstring"          # Write the content
        Write-Host -Object "`t`t`t$logstring"                         # Output to Console
    }
    
    # Example: LogWriter "Hier mein Eintrag" (mit Zeitstempel)
    # Example: LogWriter "Hier mein Eintrag" 0 (ohne Zeitstempel)
}

# Collect informations from the checkscripts
function CollectScriptInfo
{
    param
    (
        [Parameter(Mandatory = $true)][string]$Area,                      # Area of the checkScript
        [Parameter(Mandatory = $true)][string]$CheckID,                   # ID of the CheckScript (Scriptname)
        [Parameter(Mandatory = $true)][string]$CheckScriptFullPath,       # FullPath of de checkScript
        [Parameter(Mandatory = $true)][array]$products,             		# Assigned products
        [Parameter(Mandatory = $true)][bool]$PreCheck,             		# State of preCheck
        [Parameter(Mandatory = $true)][bool]$QCheck             			# State of Q-Check
    )

    # Add a Row to the table
    $row = $dtScriptinfos.NewRow()  
    $row['Area'] = $Area
    $row['CheckID'] = $CheckID
    $row['ScriptPath'] = $CheckScriptFullPath
    $row['products'] = $products
    $row['PreCheck'] = $PreCheck
    $row['QCheck'] = $QCheck

    $dtScriptinfos.Rows.Add($row)
}

# Write the results...
function WriteCheckElement ([string]$Area,[bool]$State,[string]$Info,[string]$error, [string]$ShortDesc, [string]$Desc, [string]$CheckID)
{
    $stat = [string]$State
    LogWriter "`t`tID: $CheckID"
    LogWriter "`t`tStatus: $stat "
    LogWriter "`t`tArea: $Area"
    LogWriter "`t`tShort: $ShortDesc"
    LogWriter "`t`t$Desc"
    LogWriter "`t`tInfo: $Info"
    LogWriter "`t`tError: $error"
	
    $modStat = ''
    $divCSSStat = ''
	
	
    if($State -eq $true)
    {
        $modStat = 'Passed'
        $divCSSStat = "<div class=`"Passed`">"
    }
    else
    {
        $modStat = 'Failed'
        $divCSSStat = "<div class=`"Failed`">"
        $Global:RunCounterFail = $Global:RunCounterFail + 1
    }
	
    $CheckItem = @"
	$divCSSStat
        <table>
            <thead>
                <tr></tr>
                <tr>
                    <th colspan="2">CheckID: $CheckID</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Area</td>
                    <td>$Area</td>
                </tr>
                <tr>
                    <td>Short Description</td>
                    <td>$ShortDesc</td>
                </tr>
                <tr>
                    <td>Detail Description</td>
                    <td>$Desc</td>
                </tr>
                <tr>
                    <td>Additional Informations:</td>
                    <td>$Info</td>
                </tr>
                <tr>
                    <td>Error information:</td>
                    <td>$error</td>
                </tr>
                <tr>
                    <td>State Check:</td>
                    <td>$modStat</td>
                </tr>
				<tr>
                    <td></td>
                    <td></td>
                </tr>
            </tbody>
            <tfoot>
                <tr>
                    <th>Test passed</th>
                    <th>$stat</th>
                </tr>
            </tfoot>
        </table>
		</div>
"@
	
    # Add the Item to Stingbuilder
    $null = $sbItem.Append($CheckItem)
	
    # CleanUp
    $CheckItem = ''
    $Area = $null
    $State = $false
    $Info = $null
    $error = $null
    $ShortDesc = $null
    $Desc = $null
    $CheckID = $null
}


#Build the report for the checks
function ReportBuilder()
{
    $statdiv = ''
    if($RunCounterFail -eq 0)
    {
        $statdiv = "<div class=`"divstatusPassed`">All tests passed</div>"
    }
    else
    {
        $statdiv = "<div class=`"divstatusFailed`">Not all tests passed!</div>"
    }

    #Headerinformation html
    $html_Headerinfos = @"
	$statdiv
    
	<img style="width:260px" src="data:image/png;base64,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" />
	    <div class="Header">$typ Report for: $ThisServerFQDN</div>
	    <div class="Divheader">
	        <p>Created on $DateTimestamp | User: $CurrentUser</p>
	    </div>
	    <div class="headerblock">
	        Information about this system:
	    </div>
	    <div class="HeaderInformation">
	        <table>
	            <tbody>
	                <tr>
	                    <td>Servername:</td>
	                    <td>$ThisServerFQDN</td>
	                </tr>
					 <tr>
	                    <td>Description:</td>
	                    <td>$ServerDescription</td>
	                </tr>
	                <tr>
	                    <td>Domain:</td>
	                    <td>$ThisDomain</td>
	                </tr>
	                <tr>
	                    <td>Operating System:</td>
	                    <td>$OperatingSystem</td>
	                </tr>
	                <tr>
	                    <td>CPU Informations:</td>
	                    <td>
						$CPULogic (Logisch) | $CPUCore (Cores)
						</td>
	                </tr>
	                <tr>
	                    <td>Memory (GB):</td>
	                    <td>$PhysicalRAM</td>
	                </tr>
	        </table> 
		</div>
		<div class="headerblock">
	            Executed checks (Products): $prod | Totally $RunCounter checks executed, <b> $Global:RunCounterFail </b> check not passed...
	        </div>	
"@

    #Put the content together
    LogWriter 'Write Html Header....'
    $null = $sb.Append($html_Begin)	
    LogWriter 'Write Html CSS....'
    $null = $sb.Append($cssStyle)
    LogWriter 'Write Html TopInfos....'
    $null = $sb.Append($html_Headerinfos)

    #Info for no executed Scripts...
    if($RunCounter -eq 0)
    {
        $null = $sb.AppendLine('<p> No Checks executed...</p>')
    }
    else
    {
        #Add Contend Checks
        LogWriter 'Write Html checkresults....'
        $cs = $sbItem.ToString()
        $null = $sb.Append($cs)
    }
    LogWriter 'Write Html Footer....'
    $null = $sb.Append($html_EndTagAndFooter)

    $cont = $sb.ToString()
    LogWriter "Create Html Report: $ResultFile"
    $null = New-Item -ItemType File -Path $ResultFile
    Set-Content -Path $ResultFile -Value $cont -Encoding UTF8
    LogWriter 'Html Report created'
}
#endregion
## #################################################

# Check Logfolder
Write-Host -Object 'check Logfolder...'
if(!(Test-Path -Path $LogFolder))
{
    Write-Host -Object 'create Logfolder...'
    $null = New-Item -ItemType Directory -Path $LogFolder
    Write-Host -Object 'Logfolder created...'
}
else
{
    Write-Host -Object 'Logfolder exists... --> OK'
}

## ################## Write header ###############################
#region WriteHeader
LogWriter '---------------------------------------------------------' 0
LogWriter '---------------------------------------------------------' 0
LogWriter "$ScriptName.ps1 `t(MasterScript for server checks)" 0
LogWriter "Version: `t`t`t$MaScriptVersion" 0
LogWriter "Script started on:`t$DateTimestamp from $CurrentUser" 0
LogWriter "RootFolder:`t`t$ScriptRootFolder" 0
LogWriter '---------------------------------------------------------' 0
LogWriter '---------------------------------------------------------' 0
LogWriter '' 0
LogWriter "PowerShell version: `t$PowerShellVersion"
LogWriter 'Parameter which this script has been started:'
LogWriter "Param ::: CheckTyp: `t`t$CheckType"  
LogWriter "Param ::: Products: `t`t$products"
LogWriter '' 0 
#endregion
## ################## End write header ###############################


# ########################## Pre Checks ############################
#region PreChecks

# Check for the Scriptfolder with the checkscripts
LogWriter "Check $RootRelCheckScripts"
if(!(Test-Path -Path $RootRelCheckScripts))
{
    LogWriter "Script aborted! $RootRelCheckScripts not found"
    throw [System.IO.DirectoryNotFoundException] "$RootRelCheckScripts not found, script aborted!"
}
else
{
    LogWriter 'ScriptFolder exist --> OK'
}
#endregion
# #########################################################################

## ################## Html code... !!! Do not change !!! ###############################
#region html definitions
$html_Begin = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>$typ Report for $ThisServerFQDN</title>
</head>
<body>
"@

$cssStyle = @"
<style>
.Header,caption{font-weight:700}caption,div.Failed tfoot,td,th{text-align:left}body{font-family:'Helvetica Neue',Helvetica,Arial;font-size:14px;line-height:20px;font-weight:400;width:95%;margin-left:auto;margin-right:auto;background:#fff}.Divheader{margin-top:10px;padding-top:3px}.Header{margin:10px 0;color:#424242;font-size:18pt}.DivFooter{padding:5px;color:#A4A4A4;width:100%;margin-top:10px}hr{border:0;height:1px;background-image:linear-gradient(to right,rgba(0,0,0,0),rgba(0,0,0,.75),rgba(0,0,0,0))}div.HeaderInformation{padding:10px;box-shadow:1px 2px 4px rgba(0,0,0,.4);border:1px solid #D8D8D8;margin-bottom:20px;width:600px}div.HeaderInformation table{border:none;margin-bottom:20px}div.Failed,div.Passed{margin-bottom:10px;padding:5px 5px 5px 55px;background-position:left top;background-repeat:no-repeat}div.HeaderInformation table tr{background-color:#fff}div.Passed{background-image:url(data:image/png;base64,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)}div.Failed{background-image:url(data:image/png;base64,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)}table{font-family:"Helvetica Neue",Helvetica,sans-serif;width:100%;border:1px solid #f5f5f5}caption{color:silver;text-transform:uppercase;padding:5px}thead{background:#4682b4;color:#fff}td,th{padding:5px 10px;vertical-align:top}tbody tr:nth-child(even){background:#f5f5f5}tbody tr td:nth-child(1){width:200px;font-weight:600}div.Passed tfoot{background:#2e8b57;color:#fff;text-align:left}div.Failed tfoot{background:#ea6153;color:#fff}div.headerblock{font-size:16px;font-weight:600;margin:10px 0;color:#6E6E6E}.divstatusFailed,.divstatusPassed{float:right;box-sizing:content-box;font-size:22px;font-weight:600;margin-top:30px}table.errortable tbody tr td:nth-child(1){width:auto;font-weight:600}table.errortable thead{background:#6E6E6E;color:#fff}table.infotable tbody tr td:nth-child(1){width:auto;font-weight:600}table.infotable thead{background:#6E6E6E;color:#fff}.divstatusPassed{color:green}.divstatusFailed{color:Red}
</style>
"@

$html_EndTagAndFooter = @"
<div class="DivFooter">
    <hr />
    &#xa9; by Swisscom | x86 &#x26; Cloud Automation | Version $MaScriptVersion</div>
</body>
</html>
"@
#endregion

# #################### Collect informations #############################
#region Collect informations about the checkscripts

LogWriter 'Get the CheckScripts...'

# Get the checkScripts
$CheckScripts = Get-ChildItem -Path $RootRelCheckScripts -Filter *.ps1
LogWriter 'Collect Informations...'
LogWriter '' 0

ForEach ($Check in $CheckScripts)# Loop through the check scripts
{
    # 	LogWriter "::: Initialize $Check :::" 
    #	LogWriter ":::::::::::::::::::::::::::::::::" 
    $CheckScript = $Check.Fullname

    # Check if the script exists
    IF (!(Test-Path -Path $CheckScript))
    {
        LogWriter "$CheckScript not found!!!!"
    }
    else    # Script exists
    {
        try
        {
            $rsc = "`"" + $CheckScript + "`""
            # Collect information
            $expressionInfo = "& $rsc -Collectinfo `$true"
            Invoke-Expression -Command $expressionInfo 
            LogWriter "$Check Collected: $?"  # Write logentry
        }
        catch [Exception]  # The following OC-Check Script is corrupt or invalid
        {
            LogWriter "$Check is corrupt!!!! Error: $_.Exception.Message; "
        }
    }
		
    $CheckScript = ''
}

LogWriter '' 0

# Sort the colleted data...
$dw.Sort = 'Area ASC, CheckID ASC' # Sort the collected informtions of the checkscrips...
#endregion
# #################### End Collect informations #############################

# #################### Run the check sripts #############################
#region run check scipts

#Lootp through  the datatble with the collected checkscripts
foreach ($csItem in $dw)
{
    $runCheckId = $csItem.CheckID		# Get the CheckID of the script
    $collectedProd = $csItem.products	# Get the products form the specific checkscript 
    $fullcspath = $csItem.ScriptPath	# Get the scriptpath from the checkscript
    $statePreCheck = $csItem.PreCheck	# Get the state of the PreCheck boolean
    $stateQCheck = $csItem.QCheck		# Get the state of the QCheck boolean

    $counter = $products |
    Where-Object -FilterScript {
        $collectedProd -contains $_
    } |
    Measure-Object #Check if the products match
    $matchcounter = $counter.Count

    if($matchcounter -gt 0)
    {
        # The checktyp and the boolean value for the checktyp of the checkscript must be true to run this script
        if(($CheckType -eq 'qcheck' -and $stateQCheck -eq $true) -or ($CheckType -eq 'precheck' -and $statePreCheck -eq $true))
        {
            $RunCounter++	#Add item to counter...
			
            LogWriter "Execute:`t$runCheckId"
            try
            {
                $rs = "`"" + $fullcspath + "`""
                Invoke-Expression -Command "& $rs" -ErrorAction Stop
                LogWriter "Done:`t$runCheckId"
            }
            catch [Exception]
            {
                LogWriter "!!! Failed to run Check !!! :`t$_.Exception.Message;"
            }
            finally
            {
                LogWriter '' 0
            }
        }
        else
        {
            LogWriter "$runCheckId not executed --> wrong checktyp or wrong products assigned..."
        }
    }
	
    #Reset variables
    $runCheckId = $null
    $collectedProd = $null
    $fullcspath = $null
    $statePreCheck = $false
    $stateQCheck = $false
}

LogWriter ' ---------------------------------------------------------' 0
LogWriter 'Finish, all check-scripts executed...'
LogWriter "Totally $RunCounter CheckScript(s) executed"
LogWriter "$Global:RunCounterFail check(s) failed"
LogWriter '' 0

#endregion

#Call ReportBuilder
ReportBuilder

LogWriter ' ---------------------------------------------------------' 0
LogWriter "Run $ScriptName.ps1 Done..."
LogWriter ' ---------------------------------------------------------' 0
LogWriter '' 0

Invoke-Item $ResultFile