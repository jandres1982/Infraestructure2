
### Check "BUILTIN\everyone" in server folders

### Contstants
$log = 'C:\Temp\CHK_Everyone.txt'

### Main

cmd.exe /c "c:\windows\system32\notepad.exe" "c:\Temp\servers.csv"
$servers = Get-Content "c:\Temp\servers.csv"
Import-Module D:\alb\ACLs\BuiltinEverone\Get-ChildItem2.ps1
foreach ($server in $servers)
{ 
    invoke-command -ComputerName $server -ScriptBlock 
    {
        
        Function chk_everyone
        {
            $drives = Get-PSDrive -PSProvider FileSystem | Where-Object -Property name -NE "A"
            foreach ($drive in $drives)
            {
                $source = '\\' + $env:COMPUTERNAME + '\' + $drive +'$'
                $folders = Get-ChildItem2 $source -Directory -Recurse
                ForEach ($folder in $folders)
                {
                    $acls = Get-Acl $folder.FullName
                    ForEach ($acl in $acls.Access)
                   {
                        If ($acl.IdentityReference -eq "Everyone")
                        {
                            Write-Output $folder.FullName | Out-file $log -append
                        }
                    }
                }
            }
        }
        chk_everyone    
    }
}