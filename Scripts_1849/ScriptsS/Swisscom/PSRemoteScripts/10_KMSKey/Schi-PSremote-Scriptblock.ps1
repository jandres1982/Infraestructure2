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

#$ScriptRootFolder = "D:\Scripts\Swisscom\PSRemoteScripts\10_KMSKey"
#$ScriptNameFull = "D:\Scripts\Swisscom\PSRemoteScripts\10_KMSKey\Schi-PSremote-Scriptblock.ps1"


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
  
    Write-Output "Processing..."

    ############################################
    ########Put Remote commands here############
    ############################################

    #This will set the KMS reg keys to point the windows server to the Swisscom SPLA KMS Server
        
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
    New-ItemProperty -Path $RegPath -Name "KeyManagementServiceName" -Value "scsscpkms01.global.schindler.com" -PropertyType "String" -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name "KeyManagementServicePort" -Value "1688" -PropertyType "String" -Force | Out-Null
    if (Test-Path "C:\temp\SWDPSEXEC\kms_reg\install.cmd") {Remove-Item -Path "C:\temp\SWDPSEXEC\kms_reg\install.cmd" -force}    #cleanup old kms swdpsexec
    
    
    ######
    #Test Section
    #.... to be done
    Write-Output "Finished setting KMS Reg-Keys"

    ############################################
    ############################################
    ############################################
}

##################################
#Execute and output

$Log=@()
foreach ($server in $servers){
$exectime = get-date -Format s
#If WSMan works, else write error
if ([bool](Test-WSMan $server -Authentication Kerberos -ErrorAction SilentlyContinue) -eq $true) {

$Invoke = Invoke-Command -ComputerName $server -ScriptBlock $scriptToExecute -Authentication Kerberos
Write-Output "$exectime - $server - $Invoke"
$Log += "$exectime;$server; $Invoke"

}
else {
Write-Output "$exectime - $server - Test-WSMan Failed!"
$Log += "$exectime;$server; Test-WSMan Failed!"
}

}
#Write Log
$Log | Out-File "$ScriptRootFolder\logs\$DateTimestamp.csv"
# End region Main