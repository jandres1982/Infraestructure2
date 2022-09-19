<#
        .SYNOPSIS
        Check if Staticroute Task and Script are available and remove them
        
        
		.DESCRIPTION
        The script will remove the static route scheduled tasks and script
        

		.PARAMETER abc
		no parameters param description

		
        .EXAMPLE
                

        .NOTES
        Information about the type of the parameters:
                             
        # ######################################################################
        # ScriptName:   RemoveStaticRoute.ps1
        # Description:  Test and Remove Static Routes Task and Script and Reove it
        # Created by:   Erich Niffeler
        # CreateDate:   19.09.2017
        #
        # History:
        # Version 0.1 | 19.09.2017 | Erich Niffeler | First draft version
        # #####################################################################
#>

[CmdletBinding()]
<#Param(
   
   [Parameter(Mandatory=$True, Position=1)]
   [string]$package
)#>

# #################################### General ##############################
#region General definitions
$ScriptRootFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition   
$ScriptNameFull = $MyInvocation.MyCommand.Definition
$ScriptName = [IO.Path]::GetFileNameWithoutExtension($ScriptNameFull)
$CurrentUser = $env:USERNAME
$DateTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DateLog = Get-Date -Format 'yyyyMMdd'
$logdetails = "$ScriptRootFolder\logs\logdetails-$DateTimestamp.txt"
$logoverview = "$ScriptRootFolder\logs\logoverview-$DateTimestamp.csv"
#endregion General definitions
# ######################################################################

# #################################### Modules ##############################
#region Import Modules

#We need to force the logging module load here, because the argument list has to be set
#Do no force to load the logging module if you are using it within a module!

#endregion Import Modules
# ######################################################################

# #################################### Functions ##############################
#region Functions

#endregion Functions
# ######################################################################

# #################################### Variables ##############################
#region Variables
 
# Version
$ScriptVersion = '0.1' 
$servers = Get-Content "$ScriptRootFolder\_Targets\Serverliste.txt"    # Specify list of Servers
$serverdetails = @()


#endregion Variables
# ######################################################################

# #################################### Main ##############################
#region Main
"####### $exectime Script started" | Out-File $logdetails

foreach ($server in $servers){
    "** Check $server" | Out-File $logdetails -Append 
    $exectime = get-date -Format s
    $row = "" | select SERVER,STATICROUTE01,STATICROUTE01_SUN,SCRIPT
    $row.SERVER = $server

    $task = schtasks /Query /S $server
    if ($LASTEXITCODE -eq 0) {

        $task1 = schtasks /Query /tn "SHH_SRV-STATICROUTE01" /S $server
        $Message = $Error[1].ToString()
        if ($LASTEXITCODE -eq 0) {
           "Task SHH_SRV-STATICROUTE01 existiert" | Out-File $logdetails -Append
           $row.STATICROUTE01 = "Exists"
           "Remove Task SHH_SRV-STATICROUTE01" | Out-File $logdetails -Append
           schtasks /delete /tn "SHH_SRV-STATICROUTE01" /S $server /F
        }
        elseif($Message -like "*The system cannot find the*") { 
           "Task SHH_SRV-STATICROUTE01 is not set" | Out-File $logdetails -Append
           "$Message" | Out-File $logdetails -Append
           $row.STATICROUTE01 = "Deleted"
          }
        else {
           "Task SHH_SRV-STATICROUTE01 error" | Out-File $logdetails -Append
           "$Message" | Out-File $logdetails -Append
           $row.STATICROUTE01 = "Error"
        }
        $task2 = schtasks /Query /tn "SHH_SRV-STATICROUTE01_SUN" /S $server
        $Message = $Error[1].ToString()
        if ($LASTEXITCODE -eq 0) {
           "Task SHH_SRV-STATICROUTE01_SUN existiert"  | Out-File $logdetails -Append
           $row.STATICROUTE01_SUN = "Exists"
           "Remove Task SHH_SRV-STATICROUTE01" | Out-File $logdetails -Append
           schtasks /delete /tn "SHH_SRV-STATICROUTE01_SUN" /S $server /F
        } 
        elseif($Message -like "*The system cannot find the*") { 
           "Task SHH_SRV-STATICROUTE01_SUN is not set" | Out-File $logdetails -Append
           "$Message" | Out-File $logdetails -Append
           $row.STATICROUTE01_SUN = "Deleted"
          }
        else {
           "Task SHH_SRV-STATICROUTE01_SUN error" | Out-File $logdetails -Append
           "$($Error[1].ToString())" | Out-File $logdetails -Append
           $row.STATICROUTE01_SUN = "Error"
        }



        $filepath = "\\$server\c$\Program Files (x86)\LANDesk\SHH_SRV-STATICROUTE01.ps1"
        if (test-path $filepath){
          "$filepath file exists" | Out-File $logdetails -Append
          $row.SCRIPT = "Exists"
          try{
            Remove-Item $filepath -force -ErrorAction Stop
            "$filepath on $computer deleted" | Out-File $logdetails -Append
          }
          catch{
            "Error while deleting $filepath on $computer.`n$($Error[0].Exception.Message)" | Out-File $logdetails -Append
            continue
          }
  
        }
        else {
           "$filepath does not exist on $server" | Out-File $logdetails -Append
            $row.SCRIPT = "Deleted"
        }
    }
    else {
        $row.STATICROUTE01 = "Error"
        $row.STATICROUTE01_SUN = "Error"
        $row.SCRIPT = "Error"
    }
    $serverdetails += $row
}

#Write Log
$serverdetails | Export-Csv $logoverview
# End region Main