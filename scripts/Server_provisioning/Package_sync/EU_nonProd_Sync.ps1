﻿$source = "d:\provision"
$target = "\\10.37.14.28\servers\provision"
$log = "c:\temp\provision_sync_EU_nonProd.txt"
$connectTestResult = Test-NetConnection -ComputerName 10.37.14.28 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.37.14.28`" /user:`"Azure\stnonprodgeneric0001`" /pass:`"553DvxEiHCz07QEFvgmiUHxoHdXF1htL5Lu/KqWlHkBib9exZ8ClmXVwaz+nOFBhuNy0Uskes/miVH0lIw9bqA==`""
    # Mount the drive
    New-PSDrive -Name M -PSProvider FileSystem -Root "\\10.37.14.28\servers"
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
robocopy  "$Source" "$target" /E /MIR /ZB /COPYALL /MT:32 /R:1 /W:0 /LOG+:$Log
Remove-PSDrive M