
#configure the host file with: 10.166.14.8 stnonprodgeneric0002.file.core.windows.net
$connectTestResult = Test-NetConnection -ComputerName stnonprodgeneric0002.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"stnonprodgeneric0002.file.core.windows.net`" /user:`"Azure\stnonprodgeneric0002`" /pass:`"GJSSDqSkGpHFMlyQFAWMoi5hRnUu7Tzzl+MfvFDiAtpgKkPzm8T7YdwnFmePwafSrJKzOhzCEZUvmj4YYyM2hw==`""
    # Mount the drive
    New-PSDrive -Name X -PSProvider FileSystem -Root "\\stnonprodgeneric0002.file.core.windows.net\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
copy-item -path "x:\provision\" -destination "c:\" -recurse -force