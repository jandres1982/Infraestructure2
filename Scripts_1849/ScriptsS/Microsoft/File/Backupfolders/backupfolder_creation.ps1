#############################################################################
# Script: Backupfolder (Creating and set ACL)
# Author: Tarkan Koemuercue & Roger Berger
# Date: 13/11/2014
# Comments:
# Pre-Requisites: Full Control over destination folder.
#
# Table of Content:
# 1. Variables
# 2. Functions
#   Domain automatisation
#   2.1 INITIALIZATION
#   2.2 Create
#   2.3 ACL
#############################################################################

### 1. Variables ############################################################
#

param
(
    [string]$DOMAIN,
    [string]$USER,
    [string]$backuptarget="D:\test",
    $userslist_file="D:\test\users.txt"

)


# What domain are your users in?
#$domainName = "global.schindler.com"
# Print all valid directories?
$verbose = $false
#
#############################################################################

   
### 2.1 INITIALIZATION #####################################################
function func_initiatization
{
    write-host "[ INITIALIZATION ]" -ForegroundColor Blue
    ### Domain automatization ###################################################
    if($domain)
        {
            #check variable....before continue
            #...
            try{[System.DirectoryServices.ActiveDirectory.Domain]::GetDomain((New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain", $domain)))}
            catch{write-host "+ [" $domain "] " -foregroundcolor blue -noNewline; write-host $_.Exception.Message -ForegroundColor Red;EXIT 777;}
            write-host "+ [" $domain "] " -foregroundcolor blue -noNewline; write-host "targeting specified domain"
            $global:domain=$domain
        }
    else
        {
                    #script started without parameter or domain parameter was not specified. In this case we will use the current domain of the machine
                    [string]$global:domain=[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
                    [string]$global:netbiosDN=[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name.Split(".")[0].ToUpper()
                    [string]$global:strDN = "DC=" + ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name) -Replace("\.",",DC=")              
                    [string]$global:forest=([System.DirectoryServices.ActiveDirectory.Domain]::GetDomain((New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("Domain", $global:domain)))).Forest.name
                    [string]$global:forestnetbiosDN=$global:forest.Split(".")[0].ToUpper()
                    [string]$global:foreststrDN="DC=" + $global:forest.Replace("\.",",DC=")

                    write-host "+ [" $global:domain "] " -foregroundcolor blue -noNewline; write-host "targeting current computers domain"
        }

    ### User from parameters or from file ###################################################
    if (!$user)
        {
            if (test-path -Path $userslist_file)
                {
                    #just create the array without validation of the accountd against the domain
                    try{$global:usersImport=import-Csv -Path $userslist_file}
                    catch{write-host "+ [ IMPORT CSV ] " -foregroundcolor red -noNewLine;write-host $_.Exception.Message;break;}  
                    write-host "+ [ IMPORT CSV ] " -foregroundcolor blue -noNewLine;write-host $userslist_file -noNewLine;write-host " (LOADED)" -foregroundcolor blue;
                    if ($verbose){$global:usersImport|write-host "  + =>" $_.samaccountname}      
                }
            else
                {
                    write-host "+ [ IMPORT CSV ] " -foregroundcolor blue -noNewLine;write-host $userslist_file -noNewLine;write-host " (NOT LOADED)" -foregroundcolor red;      
                }
        }
    else
        {
            #just create the array without validation of the account against the domain
            $global:usersImport = $user| Select-Object -Property @{Name="SamAccountName"; Expression = {$_}}
        }
    #check access rights on Backuptarget before execution of the test-path
    if (test-path -Path $backuptarget)
        {
            write-host "+ [ BACKUP DIR ] " -foregroundcolor blue -noNewLine;write-host $($backuptarget) -noNewLine;write-host " (FOUND)" -foregroundcolor blue;      
        }
    else
        {
            write-host "+ [ BACKUP DIR ] " -foregroundcolor blue -noNewLine;write-host $($backuptarget) -noNewLine;write-host " ( NOT FOUND)" -foregroundcolor red;
            exit 666;
        }
    
    
}
#Note: do not forget to start with sameaccountname in the first column
#
### 2.2 Create Folder #######################################################
#
function func_createfolderstructureperUser ([string]$user)
    {

        $currentpath=$(-join($backuptarget,"\",$user))
         if (Test-Path -Path $currentpath)
            {
                 write-host "  + => FOLDER $currentpath (EXIST)"                
            }
        else
            {
                #create dir

                try{$null=mkdir -path $(-join($backuptarget,"\",$user))}
                catch{write-host "  + => FOLDER $currentpath (FAILED)" $_.Exception.Message -ForegroundColor Red;break}
                write-host "  + => FOLDER $currentpath (CREATED)"
            }

        # Change to the location of the home drives
        set-location $backuptarget
        # Initialise a few counter variables. Only useful for multiple executions from the same session
        $goodPermissions = $unfixablePermissions = $fixedPermissions = $badPermissions = 0
        $failedFolders = @()
     
        # dump the current ACL in a variable
        #$acl= (Get-Item $backuptarget_current).GetAccessControl("Access")
        $acl= GET-ACL $currentpath
        # create a permission mask in the form of DOMAIN\Username where Username=foldername
        $compareString = "*" + $global:domain + "\" + $user + " ReadAndExecute, Synchronize*"
     
        # if the permission mask is in the ACL
       if ($Acl.AccessToString -like $compareString) 
                {
     
                     # everything's good, increment the counter and move on.
                    if ($verbose) {Write-Host "Permissions are valid for" $user -backgroundcolor green -foregroundcolor white}
                    $goodPermissions += 1
     
                } 
       else 
                {

                     # Permissions are invalid, either fix or report
                    # increment the number of permissions needing repair
                    $badPermissions += 1
                             $username = (-join($global:domain,"\",$user))
                             #╔═════════════╦═════════════╦═══════════════════════════════╦════════════════════════╦══════════════════╦═════════════════════════════════════╦════════════════╦══════════════╗
                             #║             ║ folder only ║ folder, sub-folders and files ║ folder and sub-folders ║ folder and files ║ sub-folders and files               ║ sub-folders    ║    files     ║
                             #╠═════════════╬═════════════╬═══════════════════════════════╬════════════════════════╬══════════════════╬═════════════════════════════════════╬════════════════╬══════════════╣
                             #║ Propagation ║ none        ║ none                          ║ none                   ║ none             ║ InheritOnly                         ║ InheritOnly    ║ InheritOnly  ║
                             #║ Inheritance ║ none        ║ ContainerInherit|ObjectInherit║ ContainerInherit       ║ ObjectInherit    ║ ContainerInherit|ObjectInherit      ║ ContaineInherit║ ObjectInherit║
                             #╚═════════════╩═════════════╩═══════════════════════════════╩════════════════════════╩══════════════════╩═════════════════════════════════════╩════════════════╩══════════════╝
                            $acl = Get-Item -path $currentpath |get-acl
                            # This removes inheritance
                            $acl.SetAccessRuleProtection($true,$true)
                            $acl |Set-Acl
                            #reread ACL after removal of inheritance
                            $acl = Get-Item -path $currentpath |get-acl


                            #check and remove existing rights
                            $acl.Access|%{
                                if($_.IdentityReference.value.toUpper().contains($user.ToUpper()))
                                    {
                                        $accessLevel = $_.filesystemRights
                                        $inheritanceFlags = $_.InheritanceFlags
                                        $propagationFlags = $_.PropagationFlags
                                        $accessControlType = "Allow"
                                        $User2Remove= $_.IdentityReference
                                        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($User2Remove,$accessLevel,$inheritanceFlags,$propagationFlags,$accessControlType)
                                        try  {
                                                $null=$Acl.RemoveAccessRule($accessRule)
                                                Set-Acl -path $currentpath -AclObject $Acl
                                             }
                                        catch{
                                                 # It failed!
                                                 # Increment the fail count
                                                 $unfixablePermissions += 1
                                                 # and add the folder to the list of failed folders
                                                 $failedFolders += $user
                                                 write-host "  + => PREMISSIONS $($currentpath) (FAILED)" -ForegroundColor Red
                                              }


                                    }
                                 else
                                    {
                                          #not found ACL for this user
                                    }
                             }


                             #REMOVE USER
                             $accessLevel = "ReadandExecute"
                             $inheritanceFlags = "ContainerInherit, ObjectInherit"
                             $propagationFlags = "None"
                             $accessControlType = "Allow"
                             $User2Remove="BUILTIN\Users"
                             $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($User2Remove,$accessLevel,$inheritanceFlags,$propagationFlags,$accessControlType)
                             
                             try  {
                                    $null=$Acl.RemoveAccessRule($accessRule)
                                    Set-Acl -path $currentpath -AclObject $Acl
                                  }
                             catch{
                                     # It failed!
                                     # Increment the fail count
                                     $unfixablePermissions += 1
                                     # and add the folder to the list of failed folders
                                     $failedFolders += $user
                                     write-host "  + => PREMISSIONS $($currentpath) (FAILED)" -ForegroundColor Red
                                   }
                             
                             #READ RIGHT (FOLDER,SUBFOLDER AND FILES)
                             $accessLevel = "Read"
                             $inheritanceFlags = "ContainerInherit , ObjectInherit"
                             $propagationFlags = "None"
                             $accessControlType = "Allow"
                             $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,$accessLevel,$inheritanceFlags,$propagationFlags,$accessControlType)
                             try 
                                {
                                     $null=$Acl.SetAccessRule($accessRule)
                                     Set-Acl $currentpath $Acl
                                     # if it hasn't errored out by now, increment the counter
                                     $fixedPermissions += 1
                                 } 
                             catch 
                                 {
                                     # It failed!
                                     # Increment the fail count
                                     $unfixablePermissions += 1
                                     # and add the folder to the list of failed folders
                                     $failedFolders += $user
                                     write-host "  + => PREMISSIONS $($currentpath) (FAILED)" -ForegroundColor Red
                                 }

                             #CREATE RIGHT (FOLDER ONLY)
                             $accessLevel = "CreateDirectories"
                             $inheritanceFlags = "None"
                             $propagationFlags = "None"
                             $accessControlType = "Allow"
                             $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,$accessLevel,$inheritanceFlags,$propagationFlags,$accessControlType)
                             try 
                                {
                                     $null=$Acl.AddAccessRule($accessRule)
                                     Set-Acl $currentpath $Acl
                                     # if it hasn't errored out by now, increment the counter
                                     $fixedPermissions += 1
                                 } 
                             catch 
                                 {
                                     # It failed!
                                     # Increment the fail count
                                     $unfixablePermissions += 1
                                     # and add the folder to the list of failed folders
                                     $failedFolders += $user
                                     write-host "  + => PREMISSIONS $($currentpath)) (FAILED)" -ForegroundColor Red
                                 }
                             #FULL RIGHT (FILES ONLY)
                             $accessLevel = "FullControl"
                             $inheritanceFlags = "ObjectInherit"
                             $propagationFlags = "InheritOnly"
                             $accessControlType = "Allow"
                             $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,$accessLevel,$inheritanceFlags,$propagationFlags,$accessControlType)
                             try 
                                {
                                     $null=$Acl.AddAccessRule($accessRule)
                                     Set-Acl $currentpath $Acl
                                     # if it hasn't errored out by now, increment the counter
                                     $fixedPermissions += 1
                                 } 
                             catch 
                                 {
                                     # It failed!
                                     # Increment the fail count
                                     $unfixablePermissions += 1
                                     # and add the folder to the list of failed folders
                                     $failedFolders += $user
                                     write-host "  + => PREMISSIONS $($currentpath) (FAILED)" -ForegroundColor Red
                                 }
                             #FULL RIGHT (SUBFOLDER AND FILES ONLY)
                             $accessLevel = "FullControl"
                             $inheritanceFlags = "ContainerInherit , ObjectInherit"
                             $propagationFlags = "InheritOnly"
                             $accessControlType = "Allow"
                             $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,$accessLevel,$inheritanceFlags,$propagationFlags,$accessControlType)
                             try 
                                {
                                     $null=$Acl.AddAccessRule($accessRule)
                                     Set-Acl $currentpath $Acl
                                     # if it hasn't errored out by now, increment the counter
                                     $fixedPermissions += 1
                                 } 
                             catch 
                                 {
                                     # It failed!
                                     # Increment the fail count
                                     $unfixablePermissions += 1
                                     # and add the folder to the list of failed folders
                                     $failedFolders += $user
                                     write-host "  + => PREMISSIONS $($currentpath) (FAILED)" -ForegroundColor Red
                                 }

                            write-host "  + => PREMISSIONS $($currentpath) (CONFIGURED)"
            
                } #/if

     
        # Print out a summary
     
        #Write-Host ""
        #Write-Host $goodPermissions "valid permissions"
        #Write-Host $badPermissions "permissions needing repair"
        #if ($reportMode -eq $false) {Write-Host $fixedPermissions "permissions fixed"}
        #if ($unfixablePermissions -gt 0) 
        #    {
        #        Write-Host $unfixablePermissions "ACLs could not be repaired."
        #        foreach ($folder in $failedFolders) 
        #            {Write-Host " -" $folder}
        #   }


        

    }
    

#############################################################################  MAIN SECTION
func_initiatization
write-host ""
write-host "";write-host "[ CONFIGRUATION ]" -ForegroundColor Blue
write-host "+ [ USER ] " $($_.samaccountname) -foregroundcolor blue;
$global:usersImport|%{func_createfolderstructureperUser $_.samaccountname}