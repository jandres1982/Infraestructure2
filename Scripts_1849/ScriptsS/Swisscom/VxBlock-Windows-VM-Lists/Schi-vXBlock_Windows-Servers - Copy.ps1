<#
        .SYNOPSIS
        Create a list of Windows Servers from vCenter
        
		.DESCRIPTION
        Create a list of Windows Servers from vCenter. List only contains FQDN of Windows Servers
        so it can be used in other scripts (e.g. PSremoting)
        

		.PARAMETER abc
		param description

		.PARAMETER xyz
		param description
		
        .EXAMPLE
                

        .NOTES
        Information about the type of the parameters:
                             
        # ######################################################################
        # ScriptName:   Schi-vWindows-Server.ps1
        # Description:  Create a list of Windows Servers from vCenter
        # Created by:   Michael Barmettler
        # CreateDate:   19.06.2017
        #
        # History:
        # Version 0.1 | 19.06.2017 | Michael Barmettler | First draft version
        # #####################################################################
#>

# #################################### General ##############################
#region General definitions
$ScriptRootFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition   
$ScriptNameFull = $MyInvocation.MyCommand.Definition

#$ScriptRootFolder = "D:\Scripts\Swisscom\VxBlock-Windows-VM-Lists\"
#$ScriptNameFull = "D:\Scripts\Swisscom\VxBlock-Windows-VM-Lists\Schi-vXBlock_Windows-Servers.ps1"


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

# Loading VMware Modules

if (-not (Get-Module -Name "VMware.VimAutomation.Core")) {
    Import-module -name VMware.VimAutomation.Core -Force
 } 


#endregion Import Modules
# ######################################################################

# #################################### Variables ##############################
#region Variables
 
# Version
$ScriptVersion = '0.1' 
$vcenters = "vcenterscs.global.schindler.com"                                              #vCenter Server
$username = "SA-PF01-vCSchiRO@itoper.local"


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

$ViCredentials = Get-CredentialFile -username $username

Connect-VIServer $vcenters -Credential $ViCredentials

function Get-VMFolderPath {  
 <#  
 .SYNOPSIS  
 Get folder path of Virtual Machines  
 .DESCRIPTION  
 The function retrives complete folder Path from vcenter (Inventory >> Vms and Templates)  
 .NOTES   
 Author: Kunal Udapi  
 http://kunaludapi.blogspot.com  
 .PARAMETER N/a  
 No Parameters Required  
 .EXAMPLE  
  PS> Get-VM vmname | Get-VMFolderPath  
 .EXAMPLE  
  PS> Get-VM | Get-VMFolderPath  
 .EXAMPLE  
  PS> Get-VM | Get-VMFolderPath | Out-File c:\vmfolderPathlistl.txt  
 #>  
  #####################################    
  ## http://kunaludapi.blogspot.com    
  ## Version: 1    
  ## Windows 8.1   
  ## Tested this script on    
  ## 1) Powershell v4    
  ## 2) VMware vSphere PowerCLI 6.0 Release 1 build 2548067    
  ## 3) Vsphere 5.5    
  #####################################    
   Begin {} #Begin  
   Process {  
     foreach ($vm in $Input) {  
       $DataCenter = $vm | Get-Datacenter  
       $DataCenterName = $DataCenter.Name  
       $VMname = $vm.Name  
       $VMParentName = $vm.Folder  
       if ($VMParentName.Name -eq "vm") {  
         $FolderStructure = "{0}\{1}" -f $DataCenterName, $VMname  
         $FolderStructure  
         Continue  
       }#if ($VMParentName.Name -eq "vm")  
       else {  
         $FolderStructure = "{0}\{1}" -f $VMParentName.Name, $VMname  
         $VMParentID = Get-Folder -Id $VMParentName.ParentId  
         do {  
           $ParentFolderName = $VMParentID.Name  
           if ($ParentFolderName -eq "vm") {  
             $FolderStructure = "$DataCenterName\$FolderStructure"  
             $FolderStructure  
             break  
           } #if ($ParentFolderName -eq "vm")  
           $FolderStructure = "$ParentFolderName\$FolderStructure"  
           $VMParentID = Get-Folder -Id $VMParentID.ParentId  
         } #do  
         until ($VMParentName.ParentId -eq $DataCenter.Id) #until  
       } #else ($VMParentName.Name -eq "vm")  
     } #foreach ($vm in $VMList)  
   } #Process  
   End {} #End  
 } #function to get the folder path of a VM


#Get all running VMs in vCenter and query the Folder Path, OS and Hostname
$vms = Get-vm | Where-Object {$_.PowerState -eq "PoweredOn"} | select name, @{n="FolderPath"; e={$_ | Get-VMFolderPath}}, @{n="OS"; e={$_.guest.OSFullName}}, @{n="HostName"; e={$_.guest.HostName}}

#Filter out VMs based on Domain, OS, Folder
$Windows_GlobalDOM_NOIDM_NOCITRIX = $vms | Where-Object {$_.FolderPath -notlike "*Citrix*" -and $_.FolderPath -notlike "*IM*" -and $_.HostName -like "*.global*" -and $_.OS -like "*Windows*"} | select name, FolderPath, HostName, OS | sort name
$Windows_DMZ2DOM_NOIDM_NOCITRIX = $vms | Where-Object {$_.FolderPath -notlike "*Citrix*" -and $_.FolderPath -notlike "*IM*" -and $_.HostName -like "*dmz*" -and $_.OS -like "*Windows*"} | select name, FolderPath, HostName, OS | sort name
$Windows_TSTDOM_NOIDM_NOCITRIX = $vms | Where-Object {$_.FolderPath -notlike "*Citrix*" -and $_.FolderPath -notlike "*IM*" -and $_.HostName -like "*.tst*" -and $_.OS -like "*Windows*"} | select name, FolderPath, HostName, OS | sort name
$Windows_LegacyDOM_NOIDM_NOCITRIX = $vms | Where-Object {$_.FolderPath -notlike "*Citrix*" -and $_.FolderPath -notlike "*IM*" -and $_.HostName -notlike "*.tst*" -and $_.HostName -notlike "*dmz*" -and $_.HostName -notlike "*.global*" -and $_.HostName -like "*.*.schindler.com*" -and $_.OS -like "*Windows*"} | select name, FolderPath, HostName, OS | sort name
$Windows_SchindlerDOM_NOIDM_NOCITRIX = $vms | Where-Object {$_.FolderPath -notlike "*Citrix*" -and $_.FolderPath -notlike "*IM*" -and $_.HostName -notlike "*.tst*" -and $_.HostName -notlike "*dmz*" -and $_.HostName -notlike "*.global*" -and $_.HostName -notlike "*.*.schindler.com*" -and $_.HostName -like "*.schindler.com*" -and $_.OS -like "*Windows*"} | select name, FolderPath, HostName, OS | sort name
$Windows_ADROOTDOM_NOIDM_NOCITRIX = $vms | Where-Object {$_.FolderPath -notlike "*Citrix*" -and $_.FolderPath -notlike "*IM*" -and $_.HostName -like "*.adroot*" -and $_.OS -like "*Windows*"} | select name, FolderPath, HostName, OS | sort name
$Windows_NODOM_NOIDM_NOCITRIX = $vms | Where-Object {$_.FolderPath -notlike "*Citrix*" -and $_.FolderPath -notlike "*IM*" -and $_.HostName -notlike "*.tst*" -and $_.HostName -notlike "*dmz*" -and $_.HostName -notlike "*.global*" -and $_.HostName -notlike "*.*.schindler.com*" -and $_.HostName -notlike "*.schindler.com*" -and $_.OS -like "*Windows*"} | select name, FolderPath, HostName, OS | sort name
$Windows_Unmanaged_CITRIX = $vms | Where-Object {$_.OS -like "*Windows*" -and $_.FolderPath -like "*Citrix*"} | select name, FolderPath, HostName, OS | sort name
$Windows_IM = $vms | Where-Object {$_.OS -like "*Windows*" -and $_.FolderPath -like "*IM*"} | select name, FolderPath, HostName, OS | sort name
$Windows_ALL = $vms | Where-Object {$_.OS -like "*Windows*"} | select name, FolderPath, HostName, OS | sort name


$Windows_GlobalDOM_NOIDM_NOCITRIX_count = ($Windows_GlobalDOM_NOIDM_NOCITRIX | Measure-Object).count
$Windows_DMZ2DOM_NOIDM_NOCITRIX_count = ($Windows_DMZ2DOM_NOIDM_NOCITRIX | Measure-Object).count
$Windows_TSTDOM_NOIDM_NOCITRIX_count = ($Windows_TSTDOM_NOIDM_NOCITRIX | Measure-Object).count
$Windows_LegacyDOM_NOIDM_NOCITRIX_count = ($Windows_LegacyDOM_NOIDM_NOCITRIX | Measure-Object).count
$Windows_SchindlerDomDOM_NOIDM_NOCITRIX_count = ($Windows_SchindlerDOM_NOIDM_NOCITRIX | Measure-Object).count
$Windows_ADRootDomDOM_NOIDM_NOCITRIX_count = ($Windows_ADRootDOM_NOIDM_NOCITRIX | Measure-Object).count
$Windows_NODOM_NOIDM_NOCITRIX_count = ($Windows_NODOM_NOIDM_NOCITRIX | Measure-Object).count
$Windows_Unmanaged_CITRIX_count = ($Windows_Unmanaged_CITRIX | Measure-Object).count
$Windows_IM_count = ($Windows_IM | Measure-Object).count
$Windows_ALL_count = ($Windows_ALL | Measure-Object).count


$Windows_TSTDOM_NOIDM_NOCITRIX.Hostname | out-file "$ScriptRootFolder\output\00_WIN_TSTDOM_NOIDM_NOCITRIX\$DateTimestamp-WIN_TSTDOM_NOIDM_NOCITRIX-Count$Windows_TSTDOM_NOIDM_NOCITRIX_count.txt"
$Windows_DMZ2DOM_NOIDM_NOCITRIX.Hostname | out-file "$ScriptRootFolder\output\01_WIN_DMZ2DOM_NOIDM_NOCITRIX\$DateTimestamp-WIN_DMZ2DOM_NOIDM_NOCITRIX-Count$Windows_DMZ2DOM_NOIDM_NOCITRIX_count.txt"
$Windows_GlobalDOM_NOIDM_NOCITRIX.Hostname | out-file "$ScriptRootFolder\output\02_WIN_GlobalDOM_NOIDM_NOCITRIX\$DateTimestamp-WIN_GlobalDOM_NOIDM_NOCITRIX-Count$Windows_GlobalDOM_NOIDM_NOCITRIX_count.txt"
$Windows_LegacyDOM_NOIDM_NOCITRIX.Hostname | out-file "$ScriptRootFolder\output\03_WIN_LegacyDOM_NOIDM_NOCITRIX\$DateTimestamp-WIN_LegacyDOM_NOIDM_NOCITRIX-Count$Windows_LegacyDOM_NOIDM_NOCITRIX_count.txt"

$Windows_SchindlerDOM_NOIDM_NOCITRIX.Hostname | out-file "$ScriptRootFolder\output\50_WIN_SchindlerDOM_NOIDM_NOCITRIX\$DateTimestamp-WIN_SchindlerDOM_NOIDM_NOCITRIX-Count$Windows_SchindlerDOM_NOIDM_NOCITRIX_count.txt"
$Windows_ADRootDOM_NOIDM_NOCITRIX.Hostname | out-file "$ScriptRootFolder\output\50_WIN_ADrootDOM_NOIDM_NOCITRIX\$DateTimestamp-WIN_ADRootDOM_NOIDM_NOCITRIX-Count$Windows_ADRootDOM_NOIDM_NOCITRIX_count.txt"
$Windows_NODOM_NOIDM_NOCITRIX.Hostname | out-file "$ScriptRootFolder\output\51_WIN_NODOM_NOIDM_NOCITRIX\$DateTimestamp-WIN_NODOM_NOIDM_NOCITRIX-Count$Windows_NODOM_NOIDM_NOCITRIX_count.txt"
$Windows_Unmanaged_CITRIX.Hostname | out-file "$ScriptRootFolder\output\52_WIN_Unmanaged_CITRIX\$DateTimestamp-WIN_Unmanaged_CITRIX-Count$Windows_Unmanaged_CITRIX_count.txt"
$Windows_IM.Hostname | out-file "$ScriptRootFolder\output\53_WIN_IM-Folder\$DateTimestamp-WIN_IM-Folder-Count$Windows_IM_count.txt"
$Windows_ALL.Hostname | out-file "$ScriptRootFolder\output\99_WIN_ALL\$DateTimestamp-WIN_ALL-Count$Windows_ALL_count.txt"


# End region Main
