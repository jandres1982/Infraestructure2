#Ip used: the ip used is from the private endpoint of the Storage account stprodgeneric0002 
$connectTestResult = Test-NetConnection -ComputerName 10.44.17.4 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.44.17.4`" /user:`"localhost\stnonprodgeneric0003`" /pass:`"u0VSqWgktW8zvbxUq0SPiklDTJSj7selW1A83OkKuzjjQiH1w99wxwlV7F+0g9Qx34zaVDkJmeOq5WNQBqMcOQ==`""
    # Mount the drive
    New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.44.17.4\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
copy-item -path "x:\provision\" -destination "c:\" -recurse -force