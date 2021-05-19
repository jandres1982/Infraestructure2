$source = "d:\provision"
$target = "x:\provision"
$log = "c:\temp\provision_sync_AP.txt"
$connectTestResult = Test-NetConnection -ComputerName 10.87.14.6 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.87.14.6`" /user:`"Azure\stgenericap0003`" /pass:`"6d3ebecvALianZFs/1NY6nTkhcxY8Ef4G+C4pqvjeuphtvWxOG7I6Gq18clZZuT7omgZUvUVoxg4QnADb6pD6A==`""
    # Mount the drive
    New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.87.14.6\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
robocopy  "$Source" "$target" /E /MIR /ZB /COPYALL /MT:32 /R:1 /W:0 /LOG+:$Log
Remove-PSDrive X