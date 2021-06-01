$source = "d:\provision"
$target = "\\10.165.14.9\servers\provision"
$log = "c:\temp\provision_sync_AM_Prod.txt"
$connectTestResult = Test-NetConnection -ComputerName 10.165.14.9 -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"10.165.14.9`" /user:`"Azure\stprodgeneric0002`" /pass:`"jRmy/4OLwP0KPste5SNkXhTjki4xV2AQACtK7LY3qdF02Q4q6nqhBQqq0BhVAt+cygzDxG/S3/rh8XEenoV5zg==`""
    # Mount the drive
    New-PSDrive -Name P -PSProvider FileSystem -Root "\\10.165.14.9\servers"
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
robocopy  "$Source" "$target" /E /MIR /ZB /COPYALL /MT:32 /R:1 /W:0 /LOG+:$Log
Remove-PSDrive P