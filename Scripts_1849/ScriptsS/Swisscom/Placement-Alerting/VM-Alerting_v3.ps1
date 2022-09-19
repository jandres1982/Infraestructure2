#===================================================================================#
#                                                                                   #
# VM-Placement-Alerting.ps1                                                         #
# Powershell script to check VMs location (Folder for Backup).                      #
# The rule is that NO VM on the vXBlock shall be in the root directory. Send alert  #
# if violated. (Resource pools are not given anymore, thus, removing it again...)   #
# Update 04.10: Add DRS Group assignment alerting to check that all VMs             #
# DS (Dualsite) storage are always assigned an Affinity-Rule                        #
#                                                                                   #
# Author: Michael Barmettler                                                        #
# Creation Date: 30.06.2016                                                         #
# Modified Date: 04.10.2016                                                         #
# Version: 02.00.00                                                                 #
#                                                                                   #
# Example: powershell.exe .\VM-Placement-Alerting.ps1                               #
#                                                                                   #
#===================================================================================#

#Load DRS Group Module
Import-Module D:\Scripts\Swisscom\Placement-Alerting\DRSRule

function Get-VCCredential {
param( )

#initialize variables
$AdminName = $env:USERNAME
$Username = "SA-PF01-vCSchiRO@itoper.local"
$Path = "D:\Scripts\Swisscom\Placement-Alerting\"
$CredsFile = "$Path$AdminName-VCCreds.txt"

$FileExists = Test-Path $CredsFile

if  ($FileExists -eq $false) {
    $Cred = Get-Credential -Message "VCenterSCS Credentials" -UserName $username
    $Cred.Password | ConvertFrom-SecureString | Out-File $CredsFile
}
else
    {Write-Host 'Using your stored credential file' -ForegroundColor Green
    $password = get-content $CredsFile | convertto-securestring
    $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username,$password}

sleep 2
Return $cred
} #function to get and store the vCenter credentials
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

################################################################################################
# Connect to vCenterSCS
Add-PSSnapin -Name VMware*
$VIServer = "vcenterscs.global.schindler.com"
$Credentials = Get-VCCredential
Connect-VIServer -Server $VIServer -Credential $Credentials

######################################################################################

#Get all VMs in vCenter and query the Folder Path and Datastore Name
$vms = Get-vm | select name, @{n="Datastore"; e={$_ | Get-Datastore}}, @{n="FolderPath"; e={$_ | Get-VMFolderPath}}

#Get all VMs who are in a DRS Affinity Group
$drsvmgroup = (Get-DRSVMGroup).vm

#Filter out VMs that are NOT in a VM Folder with name "*Backup*"
$NOBF = $vms | Where-Object {$_.FolderPath -notlike "*Backup*"} | select name | sort name

#Filter out VMs on DS (Dualsite Storage)
$DSVMs = $vms | Where-Object {$_.Datastore -like "*DS*"} | select name -ExpandProperty name | sort name

#Compare List of DS VMs with DRS Affinity Group. Filter out VMs that are NOT in DRS Group
$nodrsgroup = Compare-Object $DSVMs $drsvmgroup | Where-Object {$_.SideIndicator -eq "<="} | select InputObject | sort InputObject


#Send Mail (except if no VM is listed)
if (!$NOBF -and !$nodrsgroup) {
Write-Host "ALL OK. nothing to alert"
}
else {
$PSEmailServer = "smtp.eu.schindler.com"
$From = "$env:computername@ch.schindler.com"
$To = "michael.barmettler@ch.schindler.com" , "scc.support@ch.schindler.com", "inf.dc.se@ch.schindler.com"
$Subject = "VM Placement Alert SCS"
$Body0 = "Not all VMs are placed in a backup folder or ITBC VMs are not assigned a DRS Affinity Group @vCenter Swisscom. Please allocate these VMs asap."
$Body2 = "Not in a Backup-Folder:"
$Body3 = "----------------------"
$Body4 = $NOBF.name | Out-String
$Body5 = "Not assigned a DRS Site Affinity (Sta59 / Ind30):"
$Body6 = "----------------------"
$Body7 = $nodrsgroup.InputObject | Out-String
$Body = "$Body0`n`n$Body2`n$Body3`n$Body4`n`n$Body5`n$Body6`n$Body7"

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
}
