$Credential = Get-Credential
$UserName = $Credential.UserName
$Password = $Credential.GetNetworkCredential().Password
#$Server = "shhwsr1636"
#$ip = ""

C:\admin\tools\Sysinternals\PsExec.exe \\shhwsr1636 -u $UserName -p $Password -h -s cmd /c powershell.exe Test-ComputerSecureChannel -verbose
#C:\admin\tools\Sysinternals\PsExec.exe \\10.10.159.30 -u $UserName -p $Password -h -s cmd /c powershell.exe Test-ComputerSecureChannel -repair -credential (Get-credential)