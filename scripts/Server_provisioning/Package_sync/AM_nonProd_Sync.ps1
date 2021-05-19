$source = "d:\provision"
$target = "\\10.166.14.8\servers"
$log = "c:\temp\provision_sync_AM_nonProd.txt"
$connectTestResult = Test-NetConnection -ComputerName 10.166.14.8 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.166.14.8`" /user:`"Azure\stnonprodgeneric0002`" /pass:`"GJSSDqSkGpHFMlyQFAWMoi5hRnUu7Tzzl+MfvFDiAtpgKkPzm8T7YdwnFmePwafSrJKzOhzCEZUvmj4YYyM2hw==`""
    # Mount the drive
    New-PSDrive -Name Q -PSProvider FileSystem -Root "\\10.166.14.8\servers"
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
robocopy  "$Source" "$target" /E /MIR /ZB /COPYALL /MT:32 /R:1 /W:0 /LOG+:$Log
Remove-PSDrive Q