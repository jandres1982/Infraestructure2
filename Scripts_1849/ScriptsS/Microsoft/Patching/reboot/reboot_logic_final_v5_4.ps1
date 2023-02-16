<#
This script sends a message to a group of servers specified in a file and forces them to reboot after $timeleft is on 0.
The Servers are specified in the bootgroupX.txt files 
-One Server per line, Hostname, FQDN and IPs are allowed
The Message box appears every minute and has a built in counter which shows how many minutes are left till the server reboots
If the script encounters an error during the notification, stopping of serivces or restartprocedure, the errors will be logged and the script continues with the next serverobject
The account which runs this script needs to have admin rights on the remote and local server.
In order to start this script, execution policy mus't be set on the local server e.g. Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
It is possible to stop services before booting the server. To do so, specify the server in the csv file which corresponds to your bootgroup.
Note define every time only one server per line and separate it with a comma. If you want to specify multiple services, you have to add an additional line with the same servername and the second service

In order to get this script running you have to enable the following options:
Enable-WSManCredSSP -Role Client -DelegateComputer SERVERNAME
Enable-WSManCredSSP -Role Server -Force
gpedit.msc -->AT/SYS/CD/Allow Delegating Fresh Credentials -->Enable und add Servers wsman/SERVERNAME.domain
enable-psremoting -force

This is so because the functions are running on a "remotehost" (localhost) to be able to continue with the next serverobject in a foreach loop after manual error handling
#>
#Get current location of script
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#Ask user for Credentials with which he wants to run the script -->store them temporarily as a SecureString
#$user_cred = Get-Credential -Credential "$env:USERDOMAIN\$env:USERNAME"  -->Changed fix to global to have permissions for SHH Servers and INF/CRD usw. servers
$user_cred = Get-Credential -Credential "$env:USERDOMAIN\$env:USERNAME"

#initialize variables
#Define how many minutes till the Server reboots
[int]$timetoboot=2

#Define the time between the bootgroups in seconds
$time_between_bootgroups = 120

#Define the log file
$logfile = "$scriptPath\logfile $(get-date -f yyyy-MM-dd-hh-mm).txt"

#Define the file for the first bootgroup
$file1 = "$scriptPath\bootgroup1.txt"

#Define the file for the second bootgroup
$file2 = "$scriptPath\bootgroup2.txt"

#Define the file for the third bootgroup
$file3 = "$scriptPath\bootgroup3.txt"

#Define the file for the fourth bootgroup
$file4 = "$scriptPath\bootgroup4.txt"

#Define the file for the last bootgroup
$file5 = "$scriptPath\bootgroup5.txt"

#Define Servers with services which need to be stopped before restarting first bootgroup
$server_w_services_to_stop1 = "$scriptPath\server_services1.csv"

#Define Servers with services which need to be stopped before restarting second bootgroup
$server_w_services_to_stop2 = "$scriptPath\server_services2.csv"

#Define Servers with services which need to be stopped before restarting third bootgroup
$server_w_services_to_stop3 = "$scriptPath\server_services3.csv"

#Define Servers with services which need to be stopped before restarting fourth bootgroup
$server_w_services_to_stop4 = "$scriptPath\server_services4.csv"

#Define Servers with services which need to be stopped before restarting last bootgroup
$server_w_services_to_stop5 = "$scriptPath\server_services5.csv"

#Define folders to be deleted on server before restarting first bootgroup
$server_w_folders_to_delete1 = "$scriptPath\server_delete_folders1.csv"

#Define folders to be deleted on server before restarting second bootgroup
$server_w_folders_to_delete2 = "$scriptPath\server_delete_folders2.csv"

#Define folders to be deleted on server before restarting third bootgroup
$server_w_folders_to_delete3 = "$scriptPath\server_delete_folders3.csv"

#Define folders to be deleted on server before restarting fourth bootgroup
$server_w_folders_to_delete4 = "$scriptPath\server_delete_folders4.csv"

#Define folders to be deleted on server before restarting last bootgroup
$server_w_folders_to_delete5 = "$scriptPath\server_delete_folders5.csv"

#Define files in folder to be copied to same location but copy_$date folder before restarting first bootgroup
$server_w_files_to_copy1 = "$scriptPath\server_files_in_folder_to_copy1.csv"

#Define files in folder to be copied to same location but copy_$date folder before restarting second bootgroup
$server_w_files_to_copy2 = "$scriptPath\server_files_in_folder_to_copy2.csv"

#Define files in folder to be copied to same location but copy_$date folder before restarting third bootgroup
$server_w_files_to_copy3 = "$scriptPath\server_files_in_folder_to_copy3.csv"

#Define files in folder to be copied to same location but copy_$date folder before restarting fourth bootgroup
$server_w_files_to_copy4 = "$scriptPath\server_files_in_folder_to_copy4.csv"

#Define files in folder to be copied to same location but copy_$date folder before restarting last bootgroup
$server_w_files_to_copy5 = "$scriptPath\server_files_in_folder_to_copy5.csv"

<#
* * * * * * * * * * * * * * * *
*                             *
*   M A I N  F U N C T I O N  *
*                             *
* * * * * * * * * * * * * * * *
#>

#Definition of the whole restart, servicestopp and message send function
#Parameters: $Path_first = location of Serversfile, $timeleft_first = time till reboot is forced, $services_file_first = csv file with servername,service to stop
function notified_reboot($path_first, $timeleft_first, $services_file_first, $folder_deletion_file_first, $folder_copy_file_first)
{

#Notify users
notification $path_first $timeleft_first

#Stop services from CSV file before restarting the server
stop_service_from_file $services_file_first

#Copy files in first hirarchy to new folder in this path named copy_$date
move_folder_from_files $folder_copy_file_first

#Delete folder from CSV file
delete_folder_from_files $folder_deletion_file_first

#Reboot Servers from File
reboot_from_file $path_first

}

<#
* * * * * * * * * * * * * * * * *
*                               *
*   S U B  F U N C T I O N ' S  *
*                               *
* * * * * * * * * * * * * * * * *
#>


#Define a function to notify the Users during a given time
function notification($path, $timeleft)
{

#Load of System.Diagnostics to be able to create a stopwatch
[System.Reflection.Assembly]::LoadWithPartialName("System.Diagnostics")
$countdowntimer=New-Object System.Diagnostics.Stopwatch
Write-Host "Log of restartprocedure for servers in $path :"
"Log of restartprocedure for servers in $path :" | Out-File $logfile -Append

#While construct to send a message to every host in the list of $file1 and repeat it every minute
while($timeleft -gt 0)
{
$countdowntimer.Start()
foreach($_ in Get-Content $path)
{
Write-Host "Sending message to Server: $_"
$tempvar= $_
$timeleft_copy=$timeleft

#Store command as scriptblock to sent it to error_handling in order to check for errors and continue with the next server if the connection for one server failed
$inv_temp_var = 
{
param($var1, $var2)
msg * /SERVER:$var1 "A scheduled task from INF BE-SCC will be logging off all users on this server in order to do patching in $var2 minute(s), please save your work and logoff."
}
error_handling $inv_temp_var $tempvar $timeleft_copy
"Sent message to Server: $_" | Out-File $logfile -Append
}
while($countdowntimer.Elapsed.Minutes -lt 1){Write-Progress -Activity "Elapsed Time" -status $countdowntimer.Elapsed}
$countdowntimer.reset()
$timeleft--
}
}


#Define a function to stop a server and a single service
function stop_service($servername, $service)
{
Write-Host "Stopping the provided services on $servername"
"Stopping the following services on $servername :" | Out-File $logfile -Append
$inv_temp_var = 
{
param($var1, $var2, $var3)
#Get-Service -Name "$var1" -ComputerName "$var2" | Stop-Service Doesn't work in 2.0 only in 3.0
stop-service -inputobject $(get-service -ComputerName "$var2" -Name "$var1")
Get-Service -Name "$var1" -ComputerName "$var2" | Out-File $var3 -Append
}
error_handling $inv_temp_var $service $servername $logfile
}

#Define a function to delete a single folder on a server
function delete_folder($servername, $folder_path)
{
Write-Host "Deleting the provided folder on $servername"
"Deleting the following folder on $servername :" | Out-File $logfile -Append
$inv_temp_var =
{
param($var1, $var2, $var3)
#Pseudocode
# Delete folder $var1 on server $var2 | Out-File $var3 -Append
if(Test-Path $var1){
Write-Host "Delete folder $var1"
"Delete folder $var1 on server $var2" | Out-File $var3 -Append
Remove-Item $var1 -Recurse -Force
}
else{
Write-Host "Provided path for server $var2 doesn't exist"
"Path $var1 didn't exist on $var2" | Out-File $var3 -Append
}
}
error_handling $inv_temp_var $folder_path $servername $logfile
}


#Define a function to copy files in given folder to new folder on specified server
function move_folder($servername, $s_folder_path)
{
$d_folder_path = "$s_folder_path\copy_ $(get-date -f yyyy-MM-dd-hh-mm)\"
$inv_temp_var =
{
param($var1, $var2, $var3)
#Pseudocode
# Move folder $var1 on server $var2 to destination $var4 | Out-File $var3 -Append
if(Test-Path $var1){
Write-Host "Move files in root of folder $var1 to $var2"
"Move files in root of folder $var1 to $var2" | Out-File $var3 -Append
#create folder $var2
New-Item -Path $var2 -ItemType directory
#copy content of $var1 to $var2
Copy-Item "$var1\*.*" $var2
Remove-Item "$var1\*.*" -Force #Without recursive, (only files in root should be deleted)
}
else{
Write-Host "Provided path $var1 doesn't exist"
"Path $var1 doesn't exist" | Out-File $var3 -Append
}
}
error_handling $inv_temp_var $s_folder_path $d_folder_path $logfile
}


#Define a function to "feed" the delete_folder function out of a csv file
function delete_folder_from_files($folder_file_input)
{
import-csv $folder_file_input | foreach{delete_folder $_.servername $_.folderpath}
}

#Define a function to "feed" the move_folder function out of a csv file
function move_folder_from_files($m_folder_file_input)
{
import-csv $m_folder_file_input | foreach{move_folder $_.servername $_.source_folderpath}
}


#Define a function to "feed" the stop_service function out of a csv file
function stop_service_from_file($services_file_input)
{
import-csv $services_file_input  | foreach{stop_service $_.servername $_.service}
}


#Define a function which does the reboot
function reboot_from_file($file_with_servers)
{

#Wait 30 seconds before rebooting
start-sleep -Seconds 30

#Restart of servers from $file1 with force option, the restart itself will be performed out of the error_handling function
foreach($_ in Get-Content $file_with_servers){
Write-Host "Attempting to restart Server: $_"
$tempvar= $_
$inv_temp_var = 
{
param($var1, $var2)
Restart-Computer -ComputerName $var1 -Force | Out-File $var2 -Append
}
error_handling $inv_temp_var $tempvar $logfile

$_ | Out-File $logfile -Append
}

<#
Removed -ThrottleLimit 10 after force to reach compatibility with 2003 Servers, effect the default Value of max. 32 concurrent connections takes affect
Which leads to the problem, that there's no return of the running jobs and not the data I need to feed the logfiles
Solution was to send every item to the error_handling which runs it, checks for errors, if no error it simply displays $servername done
#> 


start-sleep -Seconds $time_between_bootgroups
"End of this bootgroup" | Out-File $logfile -Append
Write-Host "End of this bootgroup"
}



#Define a errorhandler function
function error_handling($command_to_run, $use_var1, $use_var2, $use_var3)
{

#Catch all errors during the execution of the scriptblock provided to the function:
$Backup = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
trap
{
"Error caught by trap (error_handling) for Element : $_" | Out-File $logfile -Append

#Error is handled, (not forwarded to powershell) continue with script:
continue
}

#Invoke-Expression $command_to_run
Invoke-Command -ScriptBlock $command_to_run -ArgumentList $use_var1, $use_var2, $use_var3 -ComputerName $env:COMPUTERNAME -Authentication Credssp -Credential $user_cred

#Restore the previous erroraction:
$ErrorActionPreference = $Backup
}


 <#
* * * * * * * * * * * * * * * * *
*                               *
*     M A I N  S C R I P T      *
*                               *
* * * * * * * * * * * * * * * * *
#>


#Are you sure to start the script prompt
$title = 'Are you sure to proceed?'
$prompt = 'Are you sure that you want to boot all servers in the bootgroup files? Press [A] for abort or [Y] to proceed'
$abort = New-Object System.Management.Automation.Host.ChoiceDescription '&Abort', 'Aborts the Operation'
$retry = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Starts the rebootscript'
$options = [System.Management.Automation.Host.ChoiceDescription[]] ($abort, $retry)
$choice =$host.ui.PromptForChoice($title, $prompt, $options, 0)


if ($choice -eq 1)
{
#Effective main script
Write-Host "`n`n`n`nThis script will give you only a limited screen-output.`nPlease have a look at the detailed logfile in the scriptdirectory."
#Call the super function and specify the files to use, the rest of the logic will be done automatically
notified_reboot $file1 $timetoboot $server_w_services_to_stop1 $server_w_folders_to_delete1 $server_w_files_to_copy1
notified_reboot $file2 $timetoboot $server_w_services_to_stop2 $server_w_folders_to_delete2 $server_w_files_to_copy2
notified_reboot $file3 $timetoboot $server_w_services_to_stop3 $server_w_folders_to_delete3 $server_w_files_to_copy3
notified_reboot $file4 $timetoboot $server_w_services_to_stop4 $server_w_folders_to_delete4 $server_w_files_to_copy4
notified_reboot $file5 $timetoboot $server_w_services_to_stop5 $server_w_folders_to_delete5 $server_w_files_to_copy5
}
else {
Write-Host "Aborted"
}