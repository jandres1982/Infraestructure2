$connectTestResult = Test-NetConnection -ComputerName stprodgeneric0001.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"stprodgeneric0001.file.core.windows.net`" /user:`"Azure\stprodgeneric0001`" /pass:`"U7JZ4rXAfdk10d5RwkDbpC4xnhrFRW3Fnx3DJdLCN3puRBadRIyXyHZ/7e5inv3NUKOfwhiRzwELVkh5USI2Fg==`""
    # Mount the drive
    New-PSDrive -Name X -PSProvider FileSystem -Root "\\stprodgeneric0001.file.core.windows.net\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
copy-item -path "x:\provision\" -destination "c:\" -recurse -force