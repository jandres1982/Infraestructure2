$password = ConvertTo-SecureString "" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("user", $password)
$args = '-noprofile -command "Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList $env:TEMP\script.ps1"'
Start-Process powershell.exe -Credential $cred -WindowStyle Hidden -ArgumentList $args