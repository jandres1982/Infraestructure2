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
        # Version 0.2 | 19.07.2017 | Michael Barmettler | various enhancements
        # #####################################################################
#>

[CmdletBinding()]
Param(
   
   [Parameter(Mandatory=$True, Position=1)]
   [string]$package
)

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
$ScriptVersion = '0.2' 
$FoldertoCopy = "$ScriptRootFolder\_Packages\$package"              # Specify which files shall be copied.
$servers = Get-Content "$ScriptRootFolder\_Targets\$package.txt"    # Specify list of Servers



#endregion Variables
# ######################################################################

# #################################### Main ##############################
#region Main

################################
$scriptToExecute =    #Specify what you want to execute on the server in below scriptblock:
{
  
    Write-Output "Start Processing..."

    ############################################
    ####Put Remote commands in section below####
    ############################################
    
    #delete static routes, copy new version, create new static route schedules, run schedule once:

    Copy-Item "C:\temp\psremote\$using:package\SHH_SRV-STATICROUTE01.ps1" "C:\Program Files (x86)\LANDesk" -Force
    schtasks /ru "SYSTEM" /create /tn "SHH_SRV-STATICROUTE01" /tr "powershell.exe -ExecutionPolicy 'Bypass' -file 'C:\Program Files (x86)\LANDesk\SHH_SRV-STATICROUTE01.ps1'" /sc onstart /F
    schtasks /ru "SYSTEM" /create /tn "SHH_SRV-STATICROUTE01_SUN" /tr "powershell.exe -ExecutionPolicy 'Bypass' -file 'C:\Program Files (x86)\LANDesk\SHH_SRV-STATICROUTE01.ps1'" /sc weekly /d SUN /st 14:00 /F
    schtasks /run /tn "SHH_SRV-STATICROUTE01"
       
        
    ######
    #Test Section
    #Idea is to check whatever you have done above.. eg. above you set a reg key.. here you check if it actually has been created and write-output so its in log file..
    
    start-sleep -Seconds 1

    $route = route print -4
    $routecount = ($route -like "*     6*").count
    Write-Output "Number of Nubes static routes = $routecount"
    Write-Output "Finished Processing"

    ############################################
    ############################################
    ############################################
}

##################################

#Execute and output

$DatatoCopy = Get-ChildItem $FoldertoCopy

$Log=@()
foreach ($server in $servers){
$exectime = get-date -Format s

try {
    (Test-WSMan $server -Authentication Kerberos -ErrorAction Stop)
    }
Catch {
    Write-Output "$exectime - $server - $_"
    $Log += "$exectime;$server; Test-WSMAN Failed. Skipping this server"
    $testwsman = $false
    continue
}


#Copy files if there are any

if ($DatatoCopy.count -cge 1) {

    If (!(Test-Path \\$server\c$\temp\psremote\$package)) {
        mkdir \\$server\c$\temp\psremote\$package
        }
        Foreach ($object in $DatatoCopy) {
        Copy-Item $object.fullname "\\$server\c$\temp\psremote\$package\" -Force -Confirm:$false
    }
}



try {
        $Invoke = Invoke-Command -ComputerName $server -ScriptBlock $scriptToExecute -Authentication Kerberos -ErrorAction Stop
        $Log += "$exectime;$server;$Invoke"
        }
Catch {
Write-Output "$exectime - $server - $($_.Exception.Message)"
$Log += "$exectime;$server; $($_.Exception.Message)"
continue
}
}
#Write Log
$Log | Out-File "$ScriptRootFolder\logs\$package-$DateTimestamp.csv"
# End region Main