#Ip used: the ip used is from the private endpoint of the Storage account stprodgeneric0004
$connectTestResult = Test-NetConnection -ComputerName 10.76.4.197 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.76.4.197`" /user:`"localhost\stprodgeneric0004`" /pass:`"8Aas3V56zftrXBI/TyYCIPhlCA6b9g7Idx+EpPNLqP5JCvNsnbZKZuETik+GjRC42bjj+DXhPKaN+ASt1fCDuQ==`""
    # Mount the drive
    New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.76.4.197\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

copy-item -path "x:\provision\" -destination "c:\" -recurse -force

