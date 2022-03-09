#Ip used: the ip used is from the private endpoint of the Storage account stprodgeneric0002 

$connectTestResult = Test-NetConnection -ComputerName 10.44.1.4 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.44.1.4`" /user:`"localhost\stprodgeneric0003`" /pass:`"958MZdkgvmry4X5F8WUpqJlJXviSkodcIQ1KP34ONmYHCurfk9ZfonOQ3Z7AXrpAbfq4ET6a0EiTgotxvB9i/w==`""
    # Mount the drive
    New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.44.1.4\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

copy-item -path "x:\provision\" -destination "c:\" -recurse -force


