﻿Import-Module D:\Alb\ACL\Get-ChildItem2.ps1

$folders = Get-ChildItem2 '\\deuwsr4001\data$\groups' -Directory -Recurse

ForEach ($folder in $folders) {
    #$ACLs = Get-Acl $folder.FullName | ForEach-Object {$_.Access}
    $acls = Get-Acl $folder.FullName
        ForEach ($acl in $acls.Access){
            If ($acl.IdentityReference -eq "BUILTIN\Administrators"){
                If ($acl.IsInherited -eq $False){ 
                    $FileSystemRights = $acl.FileSystemRights
                    $AccessControlType = $acl.AccessControlType
                    $InheritanceF = $acl.InheritanceFlags
                    $PropagationF = $acl.PropagationFlags

                    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("GLOBAL\SHH_RES_FS_(DEU$)_F",$FileSystemRights,$InheritanceF,$PropagationF,$AccessControlType)
                    $acls.setAccessRule($accessRule)
                    $acls | Set-Acl $folder.FullName

                    Write-Output $folder.FullName | Out-file D:\Alb\Logs\ACLs\Acl_G_4001.txt -append
                }
            }
        }
}