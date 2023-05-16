####################################################################################
# Description: Install silently a Preferred Server
# Purpose: 
# Autor: David Di Certo
# Date: Feb 25th 2021
# Prerequisites:
#    - 
#
####################################################################################

param (
	[Parameter(Mandatory=$true)][string]$Var1,
	[Parameter(Mandatory=$true)][string]$Var2
)

Clear-Host

# Prompts User to Elevate PS
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe -WindowStyle Hidden "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$env:PSModulePath=[Environment]::GetEnvironmentVariable("PSModulePath","Machine")
### Initial Powershell environment global settings config ###
$ErrorActionPreference = "Stop" # Setting the session-specific error action to Terminate.
$WarningPreference='silentlycontinue' # Silencing warning messages, as we'll constantly be getting those with our SQL statements on account of user-context.
$Error.Clear() # Mainly for coding & debug-purposes ... keep Powershell's own $ERROR count relevant per individual run.
Set-StrictMode -Version Latest # Enable STRICT mode for Powershell, so we don't have any unknown/undefined variables to deal with and are less forgiving!


#################    VARS DEFINITION   #################
[string]$executingScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
[string]$LogFolder = $executingScriptDirectory + "\Logs"
[string]$LogFileName = $LogFolder + "\" + (Get-Date -Format yyyy-MM-dd_).ToString() + "_SODEXO-Azure-Import.Log.txt" # File Name of the 'regular' log file.
[int]$LogFileDays = 60

[string]$RootDrive = "C:"
[string]$RootFolder = "Ivanti_Share"
[string]$RootFolderPath = "$RootDrive\$RootFolder"
[string]$PackagesFolder = "Packages"
[string]$PatchesFolder = "Patches"
[string]$ImagesFolder = "Images"
[string]$DriversFolder = "Drivers"
[string]$hide="$" #Leave blank for visible shares
[bool]$singleShare=$True # True= Create a single share (RootFolder). False=Create 4 shares (Packages, Patches, Images, Drivers)


#################    FUNCTIONS   #################
<# 
.Synopsis 
   Write-Log writes a message to a specified log file with the current time stamp. 
.DESCRIPTION 
   The Write-Log function is designed to add logging capability to other scripts. 
   In addition to writing output and/or verbose you can write to a log file for 
   later debugging. 
.NOTES 
   Created by: Jason Wasser @wasserja 
   Modified: 11/24/2015 09:30:19 AM   
 
   Changelog: 
    * Code simplification and clarification - thanks to @juneb_get_help 
    * Added documentation. 
    * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks 
    * Revised the Force switch to work as it should - thanks to @JeffHicks 
 
   To Do: 
    * Add error handling if trying to create a log file in a inaccessible location. 
    * Add ability to write $Message to $Verbose or $Error pipelines to eliminate 
      duplicates. 
.PARAMETER Message 
   Message is the content that you wish to add to the log file.  
.PARAMETER Path 
   The path to the log file to which you would like to write. By default the function will  
   create the path and file if it does not exist.  
.PARAMETER Level 
   Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational) 
.PARAMETER NoClobber 
   Use NoClobber if you do not wish to overwrite an existing file. 
.EXAMPLE 
   Write-Log -Message 'Log message'  
   Writes the message to c:\Logs\PowerShellLog.log. 
.EXAMPLE 
   Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log 
   Writes the content to the specified log file and creates the path and file specified.  
.EXAMPLE 
   Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error 
   Writes the message to the specified log file as an error message, and writes the message to the error pipeline. 
.LINK 
   https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0 
#> 
function Write-Log 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message, 
 
        [Parameter(Mandatory=$false)] 
        [Alias('LogPath')] 
        [string]$Path='C:\Logs\PowerShellLog.log', 
         
        [Parameter(Mandatory=$false)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info", 
         
        [Parameter(Mandatory=$false)] 
        [switch]$NoClobber 
    ) 
 
    Begin 
    { 
        # Set VerbosePreference to Continue so that verbose messages are displayed. 
        $VerbosePreference = 'Continue' 
    } 
    Process 
    { 
         
        # If the file already exists and NoClobber was specified, do not write to the log. 
        if ((Test-Path $Path) -AND $NoClobber) { 
            Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name." 
            Return 
            } 
 
        # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path. 
        elseif (!(Test-Path $Path)) { 
            Write-Verbose "Creating $Path." 
            $NewLogFile = New-Item $Path -Force -ItemType File 
            } 
 
        else { 
            # Nothing to see here yet. 
            } 
 
        # Format Date for our Log File 
        $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
 
        # Write message to error, warning, or verbose pipeline and specify $LevelText 
        switch ($Level) { 
            'Error' { 
                Write-Error $Message 
                $LevelText = 'ERROR:' 
                } 
            'Warn' { 
                Write-Warning $Message 
                $LevelText = 'WARNING:' 
                } 
            'Info' { 
                Write-Verbose $Message 
                $LevelText = 'INFO:' 
                } 
            } 
         
        # Write log entry to $Path 
        "$FormattedDate $LevelText $Message" | Out-File -FilePath $Path -Append 
    } 
    End 
    { 
    } 
}

Write-Log -Message "====================== INIT ======================" -Path $LogFileName
# Cleanup older logs
Write-Log -Message ("We cleanup older files than : " + $LogFileDays + " days") -Path $LogFileName
Get-ChildItem $LogFolder -Recurse -File | Where-Object CreationTime -lt  (Get-Date).AddDays(-$LogFileDays)  | Remove-Item -Force
Write-Log -Message "Current folder: $executingScriptDirectory" -Path $LogFileName
Write-Log -Message "Current Log file: $LogFileName" -Path $LogFileName

Write-Log -Message "====================== INSTALLATION ======================" -Path $LogFileName

if ((Get-WindowsFeature Web-Server).InstallState -eq "Installed") {
    Write-Log "IIS is installed." -Path $LogFileName
}else{
    Write-Log "IIS is not installed. Let's install it !" -Path $LogFileName
}
# Install IIS
# Add-WindowsFeature NET-Framework-45-ASPNET
# Add-WindowsFeature NET-Framework-Core

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer

Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools


Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASP
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET -All
#Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CGI
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ServerSideIncludes
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebDAV
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ClientCertificateMappingAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication


#Create Root folders
New-Item -ItemType Directory -Path "$RootFolderPath" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$RootFolderPath\$PackagesFolder" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$RootFolderPath\$PatchesFolder" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$RootFolderPath\$ImagesFolder" -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$RootFolderPath\$DriversFolder" -ErrorAction SilentlyContinue

if ($singleShare) {
    if (!(Get-SMBShare -Name "$RootFolder$hide")){
	    New-SMBShare â€“Name "$RootFolder$hide" â€“Path $RootFolderPath â€“FullAccess Everyone
    }
	# IIS-Configuration
	New-WebVirtualDirectory -Site "Default Web Site" -Name $RootFolder -PhysicalPath "$RootFolderPath" -Force
#    c:\windows\system32\inetsrv\appcmd set config "Default Web Site" /section:directorybrowse /enabled:true
    Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath "IIS:\Sites\Default Web Site\$RootFolder" -Value $true

    $Acl = Get-Acl "\\localhost\$RootFolder$hide"
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Ar)
    Set-Acl "\\localhost\$RootFolder$hide" $Acl

}else{

    if (!(Get-SMBShare -Name "$PackagesFolder$hide")){
	    New-SMBShare â€“Name $PackagesFolder$hide â€“Path "$RootFolder\$PackagesFolder" â€“FullAccess Everyone
    }
    if (!(Get-SMBShare -Name "$PatchesFolder$hide")){
	    New-SMBShare â€“Name $PatchesFolder$hide â€“Path "$RootFolder\$PatchesFolder" â€“FullAccess Everyone
    }
    if (!(Get-SMBShare -Name "$ImagesFolder$hide")){
	    New-SMBShare â€“Name $ImagesFolder$hide â€“Path "$RootFolder\$ImagesFolder" â€“FullAccess Everyone
    }
    if (!(Get-SMBShare -Name "$DriversFolder$hide")){
	    New-SMBShare â€“Name $DriversFolder$hide â€“Path "$RootFolder\$DriversFolder" â€“FullAccess Everyone
    }

	# IIS-Configuration
	New-WebVirtualDirectory -Site "Default Web Site" -Name $PackagesFolder -PhysicalPath "$RootFolder\$PackagesFolder"
	New-WebVirtualDirectory -Site "Default Web Site" -Name $PatchesFolder -PhysicalPath "$RootFolder\$PatchesFolder"
	New-WebVirtualDirectory -Site "Default Web Site" -Name $ImagesFolder -PhysicalPath "$RootFolder\$ImagesFolder"
	New-WebVirtualDirectory -Site "Default Web Site" -Name $DriversFolder -PhysicalPath "$RootFolder\$DriversFolder"

#    c:\windows\system32\inetsrv\appcmd set config $PackagesFolder /section:directorybrowse /enabled:true
#    c:\windows\system32\inetsrv\appcmd set config $PatchesFolder /section:directorybrowse /enabled:true
#    c:\windows\system32\inetsrv\appcmd set config $ImagesFolder /section:directorybrowse /enabled:true
#    c:\windows\system32\inetsrv\appcmd set config $DriversFolder /section:directorybrowse /enabled:true

    Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath "IIS:\Sites\Default Web Site\$PackagesFolder" -Value $true
    Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath "IIS:\Sites\Default Web Site\$PatchesFolder" -Value $true
    Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath "IIS:\Sites\Default Web Site\$ImagesFolder" -Value $true
    Set-WebConfigurationProperty -filter /system.webServer/directoryBrowse -name enabled -PSPath "IIS:\Sites\Default Web Site\$DriversFolder" -Value $true

    $Acl = Get-Acl "\\localhost\$PackagesFolder$hide"
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Ar)
    Set-Acl "\\localhost\$PackagesFolder$hide" $Acl
    $Acl = Get-Acl "\\localhost\$PatchesFolder$hide"
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Ar)
    Set-Acl "\\localhost\$PatchesFolder$hide" $Acl
    $Acl = Get-Acl "\\localhost\$ImagesFolder$hide"
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Ar)
    Set-Acl "\\localhost\$ImagesFolder$hide" $Acl
    $Acl = Get-Acl "\\localhost\$DriversFolder$hide"
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.AddAccessRule($Ar)
    Set-Acl "\\localhost\$DriversFolder$hide" $Acl

}


# Add MIME Types
if (!(Get-WebConfigurationProperty //staticContent -Name collection[fileExtension="."])) { 
    Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -Filter "system.webServer/staticContent" -Name collection  -Value @{ fileExtension='.'; mimeType='application/application/octet-stream' }
}

if (!(Get-WebConfigurationProperty //staticContent -Name collection[fileExtension=".*"])) { 
    Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST/Default Web Site' -Filter "system.webServer/staticContent" -Name collection  -Value @{ fileExtension='.*'; mimeType='application/application/octet-stream' }
}
