#Copy Qualys package

$connectTestResult = Test-NetConnection -ComputerName 10.38.14.7 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.38.14.7`" /user:`"Azure\stprodgeneric0001`" /pass:`"U7JZ4rXAfdk10d5RwkDbpC4xnhrFRW3Fnx3DJdLCN3puRBadRIyXyHZ/7e5inv3NUKOfwhiRzwELVkh5USI2Fg==`""
    # Mount the drive
    New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.38.14.7\servers" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
copy-item -path "x:\provision\Schindler\QualysCloudAgent_5.0" -destination "d:\" -recurse -force

#Uninstall Old Qualys Agent

cmd.exe /c "C:\Program Files\Qualys\QualysAgent\Uninstall.exe" Uninstall=True Force=True

#Install New Qualys Agent

cmd.exe /c "d:\provision\Schindler\QualysCloudAgent_5.0\5.1.0.18\Binaries\Install.cmd"

#Clean Qualys package

Remove-Item -Path 'D:\provision\Schindler\QualysCloudAgent_5.0' -Recurse -Force