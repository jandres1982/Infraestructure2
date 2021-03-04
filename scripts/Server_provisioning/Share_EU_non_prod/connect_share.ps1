$connectTestResult = Test-NetConnection -ComputerName stnonprodgeneric0001.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"stnonprodgeneric0001.file.core.windows.net`" /user:`"Azure\stnonprodgeneric0001`" /pass:`"553DvxEiHCz07QEFvgmiUHxoHdXF1htL5Lu/KqWlHkBib9exZ8ClmXVwaz+nOFBhuNy0Uskes/miVH0lIw9bqA==`""
    # Mount the drive
    New-PSDrive -Name X -PSProvider FileSystem -Root "\\stnonprodgeneric0001.file.core.windows.net\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}