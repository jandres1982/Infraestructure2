<#
        .SYNOPSIS
        Import OVA files based on a trigger (.imp) file. 
   
        
              .DESCRIPTION
        This script is usually run hand in hand with an export script that places
        an .imp file and the associated .ova file on a network share.
        This script queries the network share for .imp file and in case it finds one
        it will import the VM to an ESXi host.
        

              .PARAMETER abc
              param description

              .PARAMETER xyz
              param description
              
        .EXAMPLE
                

        .NOTES
        Information about the type of the parameters:
                             
        # ######################################################################
        # ScriptName:   Schi-VMCloneImport.ps1
        # Description:  Import OVA files based on a trigger (.imp) file
        # Created by:   Michael Barmettler
        # CreateDate:   14.02.2017
        #
        # History:
        # Version 0.1 | 14.02.2017 | Michael Barmettler | First draft version
        # ######################################################################
#> 

# #################################### General ##############################
#region General definitions

#$ScriptRootFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
#$ScriptNameFull = $MyInvocation.MyCommand.Definition

$ScriptRootFolder = "D:\Scripts\Schindler\Vmware\IDM_Import"
$ScriptNameFull = "D:\Scripts\Schindler\Vmware\IDM_Import\Schi-VMCloneImport.ps1"

$ScriptName = [IO.Path]::GetFileNameWithoutExtension($ScriptNameFull)
$CurrentUser = $env:USERNAME
$DateTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DateLog = Get-Date -Format 'yyyyMMdd'
#endregion General definitions
# ######################################################################


# #################################### Variables ##############################
#region Variables

# Version
$ScriptVersion = '0.1' 

$ExportDestination = "\\sdbscpvcvmexpnas.global.schindler.com\im-qual$"          #Destination path to where the OVF shall be exported
$shareuser = "svcsdbvcscsvmexp@global.schindler.com"                             #Service account for access to remote share
$vcenter = "vcentershh.global.schindler.com"                                     #vCenter Server
$esxihost = "shhvsr0003.global.schindler.com"                                    #esxihost where the Exports shall be placed
$triggerpath = "x:\trigger"                                                      #Path to trigger files
$OVApath = "x:\OVF"                                                              #Path to OVA files

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

#endregion Variables
# ######################################################################

# #################################### Main ##############################
#region Main

<#---------------------------------------------------------------------
PHASE 1: Create PSDrive to Network-Share. Use SecureString DPAPI encryption for Password
----------------------------------------------------------------------#>
$NASCredentials = Get-CredentialFile -username $shareuser

     
New-PSDrive -Name "X" -PSProvider FileSystem -root $ExportDestination -Credential $NASCredentials -ErrorAction Stop

<#---------------------------------------------------------------------
PHASE 2: Rename trigger file. If trigger file is not on Network-Share, stop the script
----------------------------------------------------------------------#>

if (!(Test-Path $triggerpath\*.ova.imp))
    {
    Write-Host "No trigger file found"
    Remove-PSDrive -Name X -force
    Exit
    }
    else 
    {
    $triggerfiles = Get-ChildItem $triggerpath\*.ova.imp
    }

    

<#----------------------------------------------------------------------
PHASE 3: Connect to vCenter
----------------------------------------------------------------------#>
# Loading VMware Modules

if (-not (Get-Module -Name "VMware.VimAutomation.Core")) {
    Import-module -name VMware.VimAutomation.Core -Force
    }
    

Connect-VIServer -Server $vcenter

#get target host
$targethost = Get-VMhost -Name $esxihost

#Get largest datastore on the target host
$datastore = $targethost  | Get-Datastore | Sort-Object FreeSpaceGB | select -First 1

<#---------------------------------------------------------------------
PHASE 4: EXECUTION - Import OVA to host
----------------------------------------------------------------------#>

foreach ($trigger in $triggerfiles) {
$sourceova = "$($OVApath)\$($trigger.BaseName)"
$OVA = Get-ChildItem $sourceova
Rename-Item -path $trigger.FullName -newname "$($trigger.BaseName).lck" -Force
$targethost | Import-VApp -source $OVA.FullName -Datastore $datastore -Force
$importedvm = get-vm -Name $($OVA.BaseName) -ErrorAction SilentlyContinue
    if ($importedvm) 
    {
        Write-Host "VM has been found, deleting trigger and OVA on filer"
        Remove-Item -Path $($trigger.BaseName).lck -Force
        #Remove-Item -Path $OVA.FullName -Force -WhatIf
    }
    else
    {
        Write-Error "Cannot find imported VM"
    }
}

<#---------------------------------------------------------------------
PHASE 5: Cleanup
----------------------------------------------------------------------#>

Remove-PSDrive -Name "X" -Force
Disconnect-VIServer $vcenter -Force -Confirm:$false