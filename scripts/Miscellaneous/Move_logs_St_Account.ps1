$Running_Date = get-date
$logs_path = "D:\Antonio\Logs"
$logs_compress = "D:\Antonio\compressed"
$letter = "P"
$logs_path_share = "$letter"+":\logs"
$email_sender = "antoniovicente.vento@schindler.com"
$email_receiver = "antoniovicente.vento@schindler.com"
Function Mapping_Share
{
$connectTestResult = Test-NetConnection -ComputerName sttestadjoin01.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Mount the drive
    New-PSDrive -Name $letter -PSProvider FileSystem -Root "\\sttestadjoin01.file.core.windows.net\logs" -Persist -ErrorAction SilentlyContinue
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
}

###Fail email_Move
Function Fail_Email_Mv
{
$PSEmailServer = "smtp.eu.schindler.com"
$From = $email_sender
$To = $email_receiver
$Subject = "We were not able to move the logs on $Running_Date"
$Body = @"
This mail is being generated automatically by a scheduled task.
The logs couldn't be moved, please check.
"@
Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
}

###Fail email_exand
Function Fail_Email_Ex
{
$PSEmailServer = "smtp.eu.schindler.com"
$From = $email_sender
$To = $email_receiver
$Subject = "We were not able expand the logs on $Running_Date"
$Body = @"
This mail is being generated automatically by a scheduled task.
The logs couldn't be expanded, please check.
"@
Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
}

Function Success_Mail
{
$PSEmailServer = "smtp.eu.schindler.com"
$From = $email_sender
$To = $email_receiver
$Subject = "Logs were moved and expanded on $Running_Date"
$Body = @"
This mail is being generated automatically by a scheduled task.
Please, check the share $letter to check you have the logs moved
"@
Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"
}


Mapping_Share
$logs= gci -Path $logs_path

$last15day = [datetime]::Now.AddDays(-15)
foreach ($log in $logs){

    [datetime]$date = $log.LastWriteTime
    if ($date -lt $last15day)
        {
        Write-output "$log"
        Compress-Archive -Path $log.PSPath -DestinationPath "D:\Antonio\Compressed\logs.zip" -Update
        }
}

try{
Move-Item -Path "$logs_compress\logs.zip" -Destination $logs_path_share -ErrorAction Stop
}catch
    {
    Write-Output "We were not able to move the logs please check"
    Fail_Email_Mv
    Break
    }

#control
try{
Expand-Archive -Path "$logs_path_share\logs.zip" -DestinationPath $logs_path_share -ErrorAction stop
Success_Mail
Remove-Item "$logs_path_share\logs.zip"
}catch
    {
    Write-Output "We were not able to expand the logs please check"
    Fail_Email_Ex
    Break
    }


