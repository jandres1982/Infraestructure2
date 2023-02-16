<#
        .SYNOPSIS
        Execute Scriptblock on Remote Server via PSremoting (with Kerberos)
        
        
		.DESCRIPTION
        The script can be used to execute a script on a remote system. Authentication via Kerberos
        

		.PARAMETER abc
		param description

		.PARAMETER xyz
		param description
		
        .EXAMPLE
                

        .NOTES
        Information about the type of the parameters:
                             
        # ######################################################################
        # ScriptName:   Schi-PSremote-Scriptblock.ps1
        # Description:  Execute Scriptblock on remote systems
        # Created by:   Michael Barmettler
        # CreateDate:   30.06.2017
        #
        # History:
        # Version 0.1 | 30.06.2017 | Michael Barmettler | First draft version
        # #####################################################################
#>

# #################################### General ##############################
#region General definitions
$ScriptRootFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition   
$ScriptNameFull = $MyInvocation.MyCommand.Definition
$ScriptName = [IO.Path]::GetFileNameWithoutExtension($ScriptNameFull)
$CurrentUser = $env:USERNAME
$DateTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DateLog = Get-Date -Format 'yyyyMMdd'
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

#Function to securly store credentials (DPAPI encrypted, works only for the user it was stored on the system it was created..
function Get-CredentialFile {

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True, Position=1)]
   [string]$username
)

#initialize variables
$AdminName = $env:USERNAME
$Path = "$ScriptRootFolder\Credentials\"
$CredsFile = "$Path$AdminName-Creds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
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

#endregion Functions
# ######################################################################

# #################################### Variables ##############################
#region Variables
 
# Version
$ScriptVersion = '0.1' 
$servers = Get-Content "$ScriptRootFolder\servers.txt"    # Specify list of Servers



#endregion Variables
# ######################################################################

# #################################### Main ##############################
#region Main

################################
$scriptToExecute =    #Specify what you want to execute on the server in below scriptblock:
{
  
    #Write-Output "Start Processing..."

    ############################################
    ####Put Remote commands in section below####
    ############################################

    #Query PSModulePath and filter out stuff that is "default in Posh5
    $StandardPathsToFilterOut = @('%ProgramFiles%\WindowsPowerShell\Modules','%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules','%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\')
    [string[]]$currentpsmodulepath = (get-Item 'hklm:system\CurrentControlSet\Control\Session Manager\Environment').GetValue("PsModulePath","Default",[Microsoft.WIN32.RegistryValueOptions]::DoNotExpandEnvironmentNames).split(';')
    $FilteredList = ($CurrentPSModulePath | Where {$StandardPathsToFilterOut -inotcontains $_}) -join ';'
    Write-Output "PSMajorVersion: $($PSVersionTable.PSversion.Major); PSModulePathSpecial: $FilteredList"
    
    ######
    #Test Section
    #.... to be done. Idea is to check whatever you have done above.. eg. above you set a reg key.. here you check if it actually has been created and write-output so its in log file..
    
    #Write-Output "Finished Processing"

    ############################################
    ############################################
    ############################################
}

##################################
#Execute and output

$Log=@()
foreach ($server in $servers){
$exectime = get-date -Format s

try {
    (Test-WSMan $server -Authentication Kerberos -ErrorAction Stop)
    }
Catch {
    Write-Output "$exectime - $server - $_"
    $Log += "$exectime;$server;$($_.Exception.Message)"
    $testwsman = $false
}

if ($testwsman -ne $false) {

try {
        $Invoke = Invoke-Command -ComputerName $server -ScriptBlock $scriptToExecute -Authentication Kerberos -ErrorAction Stop
        $Log += "$exectime;$server;$Invoke"
        }
Catch {
Write-Output "$exectime - $server - $($_.Exception.Message)"
$Log += "$exectime;$server; $($_.Exception.Message)"

}
}
}
#Write Log
$Log | Out-File "$ScriptRootFolder\logs\$DateTimestamp.csv"
# End region Main