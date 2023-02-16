function Get-ATLocalAdminMember {
<#
	.SYNOPSIS
		Query servers for local Administrators.

	.DESCRIPTION
		Get-ATLocalAdminMember queries targets with PowerShell Remoting, and then uses the Microsoft Active Directory Module to pull AD-related information about all users that have Administrative access. This script will work against servers, as long as those servers have PowerShell Remoting enabled, and are in a domain. The machine running this script must have the Microsoft Active Directory Module installed.

	.PARAMETER ComputerName
		The target computer, or list of computers (seperated by commas), that the script will query over PowerShell remoting.
    
  .PARAMETER CheckActiveDirectory
    Run the results against Active Directory to retrieve basic AD user, and group information. This switch will also run recursively against AD, in order to reveal complete visibility of Administrators for a server.

	.PARAMETER Credential
		If running the script under alternative credentials.

	.EXAMPLE
		PS C:\> Get-ATLocalAdminMember -ComputerName SERVER101 -Credential $Creds
      Runs the script against SERVER101, returns all members of local Administrators, and queries against Active Directory for user/group information. This uses alternate credentials that have been stored in the $Creds variable, using Get-Credential.

	.EXAMPLE
		PS C:\> Get-ATLocalAdminMember -ComputerName SERVER101,SERVER102 -Credential $Creds | Export-Csv C:\temp\audit.csv -NoTypeInformation
      Runs the script against SERVER101 and SERVER102, returns all members of local Administrators, and queries against Active Directory for user/group information. This uses alternate credentials that have been stored in the $Creds variable, using Get-Credential. The results are saved in a CSV spreadsheet, C:\temp\audit.csv.

  .EXAMPLE
    PS C:\> Get-ATLocalAdminMember -ComputerName (cat c:\temp\complist.txt) | Export-Csv C:\temp\audit.csv -NoTypeInformation -Append
      Runs the script against a list of servers in complist.txt, returns all members of local Administrators, and queries against Active Directory for user/group information. This uses the credentials of the currently logged in user. The results are appended/added to a CSV spreadsheet, or it creates a new one if not currently existing, called C:\temp\audit.csv.

	.INPUTS
		System.String
    System.Management.Automation.PSCredential

	.OUTPUTS
		System.Management.Automation.PSCustomObject

	.NOTES

  .LINK
    https://github.com/ScriptAutomate/AuditTools

	.LINK
		about_Remote_Requirements

	.LINK
		about_Remote_Troubleshooting

#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$False)]
  [String[]]$ComputerName = $env:COMPUTERNAME,
  [Parameter(Mandatory=$false)]
  [Switch]$CheckActiveDirectory,
  [Parameter(Mandatory=$False)]
  [System.Management.Automation.PSCredential]$Credential
)
  if ($CheckActiveDirectory) {Import-Module ActiveDirectory -ErrorAction Stop}

  # If using alternate credentials
  if ($Credential) {
    $Sessions = New-PSSession -ComputerName $ComputerName -Credential $Credential
  }
  else {$Sessions = New-PSSession -ComputerName $ComputerName}

  if ($Sessions) {
    $LocalAdmins = Invoke-Command -Session $Sessions -ScriptBlock {
      $objSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
      $objgroup = $objSID.Translate( [System.Security.Principal.NTAccount])
      $objgroupname = ($objgroup.Value).Split("\")[1]
      $group =[ADSI]"WinNT://$($ENV:ComputerName)/$objgroupname" 
      $members = $group.psbase.Invoke("Members")
      foreach ($member in $members) {
        $MemberPath = ($member.GetType().Invokemember("ADSPath", 'GetProperty', $null, $member, $null)) -replace "WinNT://$($ENV:USERDOMAIN)/",''
        if ($MemberPath -Match "/") {
          $IsDomainAccount = $false
          $DomainName = $ENV:COMPUTERNAME
          $MemberPath = $MemberPath -replace ".*/",''
        }
        else {
          $IsDomainAccount = $true
          $DomainName = $ENV:USERDOMAIN
        }
        New-Object PSObject -Property @{
          MemberName = $member.GetType().Invokemember("Name", 'GetProperty', $null, $member, $null)
          MemberType = $member.GetType().Invokemember("Class", 'GetProperty', $null, $member, $null)
          MemberPath = $MemberPath 
          IsDomainAccount = $IsDomainAccount
          DomainName = $DomainName
        }
      } 
    }
    Remove-PSSession $Sessions

    # If the query above returned anything, run results against Active Directory
    if ($CheckActiveDirectory) {
      if ($LocalAdmins) {
        $DomainName = (Get-ADDomain).NETBIOSNAME
        # Modifying output, and querying AD
        foreach ($LocalAdmin in $LocalAdmins) {
          if ($LocalAdmin.IsDomainAccount -eq $false) {
            $IsDomainAccount = $False
            $MemberOf = "$($LocalAdmin.PSComputerName)\Administrators"
            $DN = "N/A"
            $SAMAccountName = "N/A"
            $Props = @{"Name"=$LocalAdmin.MemberName
                       "MemberType"=$LocalAdmin.MemberType
                       "PSComputerName"=$LocalAdmin.PSComputerName
                       "IsDomainAccount"=$IsDomainAccount
                       "SamAccountName"=$SamAccountName
                       "Enabled"=$Enabled
                       "AdminByMemberOf"=$MemberOf
                       "DN"=$DN}
            New-Object -TypeName PSObject -Property $Props
          }
          else {
            $IsDomainAccount = $True
            $MemberOf = "$($LocalAdmin.PSComputerName)\Administrators"
            if ($LocalAdmin.MemberType -eq "User") {
              $ADObject = Get-ADUser -Identity "$($LocalAdmin.MemberName)"
            }
            else {$ADObject = Get-ADGroup -Identity "$($LocalAdmin.MemberName)"}
            $Props = @{"Name"=$ADObject.Name
                       "MemberType"=$LocalAdmin.MemberType
                       "PSComputerName"=$LocalAdmin.PSComputerName
                       "IsDomainAccount"=$IsDomainAccount
                       "SamAccountName"=$ADObject.SamAccountName
                       "AdminByMemberOf"=$MemberOf
                       "DN"=$ADObject.DistinguishedName}
            New-Object -TypeName PSObject -Property $Props
            if ($LocalAdmin.MemberType -eq "Group") {
              $GroupMembers = Get-ADGroupMember -Identity "$($LocalAdmin.MemberName)" -Recursive
              foreach ($GroupMember in $GroupMembers) {
                $Props = @{"Name"=$GroupMember.Name
                           "MemberType"=$GroupMember.ObjectClass
                           "PSComputerName"=$LocalAdmin.PSComputerName
                           "IsDomainAccount"=$IsDomainAccount
                           "SamAccountName"=$GroupMember.SamAccountName
                           "AdminByMemberOf"=$LocalAdmin.MemberName
                           "DN"=$GroupMember.DistinguishedName}
                New-Object -TypeName PSObject -Property $Props
                Clear-Variable Props
              }
            }
            Clear-Variable Props
          }
        }
      }
    }
    else {$LocalAdmins | select * -ExcludeProperty RunspaceId,PSShowComputerName}
  }
} #End of Function Get-ATLocalAdminMember


#Get the server list 
$servers = Get-Content .\Serverlistlocaladmin.txt 

$list = @()
#Run the commands for each server in the list 
Foreach ($s in $servers) 
{
$LocalAdmins = Get-ATLocalAdminMember -ComputerName $s -CheckActiveDirectory | where-object {$_.MemberType -eq "User"} | Select PSComputerName,Name,IsDomainAccount,AdminByMemberOf -Unique
$list += $LocalAdmins
} 
$list | export-csv .\resultslocaladmin.csv -NoTypeInformation
