$source = "d:\provision"
$target = "\\10.44.1.4\servers\provision"
$log = "c:\temp\provision_sync_CH.txt"
$connectTestResult = Test-NetConnection -ComputerName 10.44.1.4 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.44.1.4`" /user:`"localhost\stprodgeneric0003`" /pass:`"958MZdkgvmry4X5F8WUpqJlJXviSkodcIQ1KP34ONmYHCurfk9ZfonOQ3Z7AXrpAbfq4ET6a0EiTgotxvB9i/w==`""
    # Mount the drive
    New-PSDrive -Name R -PSProvider FileSystem -Root "\\10.44.1.4\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
robocopy  "$Source" "$target" /E /MIR /ZB /COPYALL /MT:32 /R:1 /W:0 /LOG+:$Log
Remove-PSDrive R