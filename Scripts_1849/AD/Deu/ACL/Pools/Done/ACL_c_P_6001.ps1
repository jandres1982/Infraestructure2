Import-Module D:\Alb\ACL\Get-ChildItem2.ps1

$srv = "6001"
$kg = "DEU"
#$share = '\data$\groups\'
#$log = 'D:\Alb\Logs\ACLs\Acl_G_' + $srv +'.txt'
$share = '\data$\pools\'
$log = 'D:\Alb\Logs\ACLs\Acl_P_' + $srv +'.txt'
$source = '\\' + $kg + 'wsr' + $srv + $share

$folders = Get-ChildItem2 $source -Directory -Recurse

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

                    Write-Output $folder.FullName | Out-file $log -append
                }
            }
        }
}