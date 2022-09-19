#$XML_Path = "D:\Repository\Working\Antonio\XML_Reading\Order_SHHWSR1252.xml"
#[xml]$XML = Get-Content $XML_Path
#$XML "//Object[Property/@Name='ServiceState'


##################### Initial Parameters ##############################
#param(
#    [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$false)]
#    [System.String]
#    $hostname,
#
#    [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
#    [System.Net.IPAddress]
#    $IP,
#
#    [Parameter(Mandatory=$True, Position=2, ValueFromPipeline=$false)]
#    [System.String]
#    $Domain,
#
#
#    [Parameter(Mandatory=$True, Position=3, ValueFromPipeline=$false)]
#    [System.String]
#    $Function
#
#
#)
#

Clear-Host


$Title = "*-*-*-*-*-*-*-*-*-*-*-*-*-* Please Select an Option -*-*-*-*-*-*-*-*-*-*-*-*-*"

Clear-Host
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Script for Server Provisioning'
$form.Size = New-Object System.Drawing.Size(400,500)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(220,320)
$OKButton.Size = New-Object System.Drawing.Size(100,70)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(45,320)
$CancelButton.Size = New-Object System.Drawing.Size(100,70)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)



$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(360,20)
$label.Text = 'Include the server Hostname'
$form.Controls.Add($label)


$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textBox)
    $Font = New-Object System.Drawing.Font("Times New Roman",13,[System.Drawing.FontStyle]::regular)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Form.Font = $Font
$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
#$result = $form.ShowDialog()


##################################################################################################### Location

$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,80)
$label1.Size = New-Object System.Drawing.Size(360,20)
$label1.Text = 'Include the IP address'
$form.Controls.Add($label1)


$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(10,110)
$textBox1.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textBox1)
    $Font = New-Object System.Drawing.Font("Times New Roman",13,[System.Drawing.FontStyle]::regular)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Form.Font = $Font
$form.Topmost = $true

$form.Add_Shown({$textBox1.Select()})
#$result = $form.ShowDialog()


####################################################################################################### OS Type

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10,150)
$label2.Size = New-Object System.Drawing.Size(360,20)
$label2.Text = 'Include the domain, ex: global'
$form.Controls.Add($label2)


$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(10,180)
$textBox2.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textBox2)
    $Font = New-Object System.Drawing.Font("Times New Roman",13,[System.Drawing.FontStyle]::regular)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Form.Font = $Font
$form.Topmost = $true

$form.Add_Shown({$textBox2.Select()})
#$result = $form.ShowDialog()


######################################################################################################## Size
$label3 = New-Object System.Windows.Forms.Label
$label3.Location = New-Object System.Drawing.Point(10,220)
$label3.Size = New-Object System.Drawing.Size(360,20)
$label3.Text = 'Include the Function, Ex. test server'
$form.Controls.Add($label3)


$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(10,250)
$textBox3.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textBox3)
    $Font = New-Object System.Drawing.Font("Times New Roman",13,[System.Drawing.FontStyle]::regular)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Form.Font = $Font
$form.Topmost = $true

$form.Add_Shown({$textBox3.Select()})
#$result = $form.ShowDialog()

$result = $form.ShowDialog()



if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Hostname = $textBox.Text
    $IP = $textBox1.Text
    $Domain = $textBox2.Text
    $Function = $textBox3.Text


}
else
{
break
}


Write-host "$Hostname - $IP - $Domain - $Function"




############## Adding as trusted host and temporary setting credentials ########################################



Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$IP" -Concatenate -Force
 
$user = "localhost\Administrator"
$password = "Newsetup123"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $secureStringPwd -ErrorAction Stop

$Global_Creds = Get-Credential (whoami)

################# Script Functions ##################################
function Wait-Progress($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Waiting the Server to come up" -Status "Please wait" -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Task Paused Waiting Server to come up" -Status "Please wait" -SecondsRemaining 0 -Completed
}

Function Wait
{
while (!(Test-WSMan -ComputerName $IP -ErrorAction SilentlyContinue))
{

Wait-Progress (60)

}
}


Function Wait-on
{
while (!(Test-WSMan -ComputerName $hostname -ErrorAction SilentlyContinue))
{

Wait-Progress (60)

}
}


Function Set-WSUS
{
Invoke-command -ComputerName $IP -ScriptBlock {Write-Output 'Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate]
"ElevateNonAdmins"=dword:00000000
"WUServer"="http://shhwsr1238.global.schindler.com:8530"
"WUStatusServer"="http://shhwsr1238.global.schindler.com:8530"
"UpdateServiceUrlAlternate"=""
"TargetGroupEnabled"=dword:00000001
"TargetGroup"="SERVERS-PROD"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU]
"NoAUAsDefaultShutdownOption"=dword:00000001
"ScheduledInstallEveryWeek"=dword:00000001
"AutoInstallMinorUpdates"=dword:00000000
"DetectionFrequencyEnabled"=dword:00000001
"DetectionFrequency"=dword:00000001
"RebootWarningTimeoutEnabled"=dword:00000000
"NoAUShutdownOption"=dword:00000001
"RebootRelaunchTimeoutEnabled"=dword:00000000
"UseWUServer"=dword:00000001
"AlwaysAutoRebootAtScheduledTime"=dword:00000001
"AlwaysAutoRebootAtScheduledTimeMinutes"=dword:0000000f
"NoAutoUpdate"=dword:00000000
"AUOptions"=dword:00000004
"ScheduledInstallDay"=dword:00000001
"ScheduledInstallTime"=dword:00000008' >> C:\WSUS.reg
cmd.exe /c "reg import C:\WSUS.reg"
remove-item -path "C:\WSUS.reg"
} -Credential $creds -ErrorAction SilentlyContinue

}




################### 1st step ######################################


Write-Host "Step 1.- The Provisioning starts here!" -ForegroundColor white -BackgroundColor DarkGreen


#Task 1: Remove Client ID WSUS
Wait-Progress (10)
Wait



Invoke-command -ComputerName $IP -ScriptBlock {Remove-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\ -Name "SusClientId"} -Credential $creds -ErrorAction SilentlyContinue

#Task 2: Include WSUS parameters
Set-WSUS

#Task 3: Create Computer Object and group


Write-host "Create Computer Object and Group"
$Hostname = $hostname.ToUpper()
Write-host "Current Server: $hostname"
$KG = $hostname.Substring(0,3)
$Description = "$KG Windows Server $Function"

try
{
New-ADComputer -Name $Hostname -Path "OU=000,OU=Servers,OU=NBI12,DC=global,DC=schindler,DC=com" -PasswordNotRequired $false -Description $Description -ErrorAction SilentlyContinue
}
catch
{
Write-host "AD computer exist"
}

############################### Account with no access to create the object #########################
#$Admin_Head = "SHH_RES_SY_"
#$Admin_Tail="_ADMIN"
#$Admin_Group = "$Admin_Head$Server_UP$Admin_Tail"
#New-ADGroup -Name $Admin_Group -GroupCategory Security -GroupScope Universal -DisplayName "$hostname Administrators" -Path "OU=RES,OU=Groups,OU=Admin_Global,OU=NBI12,DC=global,DC=schindler,DC=com" -Description "$Hostname Administrators
######################### Reboot ##########################################
#Task 4: C:\temp

Invoke-command -ComputerName $IP -ScriptBlock {mkdir C:\temp} -Credential $creds -ErrorAction SilentlyContinue


#Task 5: Join the domain:


if ($Domain -clike "global")
{

if (Test-WSMan -ComputerName $Hostname -Authentication Kerberos)
{Write-host "Server $server is already en domain"
}
else
{

Write-Host "Triying to JOIN to Global Domain using your credentials" -ForegroundColor Yellow -BackgroundColor Black
try
{
Invoke-command -computername $IP -ScriptBlock {$Global_creds = $args[0]; Add-Computer -DomainName global.schindler.com -Restart -Credential $Global_Creds -ErrorAction SilentlyContinue} -Credential $creds -ArgumentList ($Global_Creds)
start-sleep (300)
}
Catch
{
Write-Host "Check computer, could be errrors to join the domain"
}

}

}else
{Write-host "Please don't use for other domains than global"
}


Wait


Write-host "Computer ready for action"





######################## 2nd step ###########################################

Write-Host "Step 2.- The Provisioning is in the 2nd step so far so good" -ForegroundColor white -BackgroundColor DarkGreen



#Task 1: Check connectivity using kerberos and copy source files.

try
{
Test-WSMan $hostname -Authentication Kerberos -Port 5985 -ErrorAction SilentlyContinue
Write-host "Copying files, please wait..."
Copy-item -Path "D:\Repository\Working\Antonio\Server_provisioning\Source" -Destination "\\$hostname\c$\temp" -Recurse -Force
$OSVersion = Invoke-Command -ComputerName $hostname -ScriptBlock {$OSVersion = [System.Environment]::OSVersion.Version | select Major; $OSVersion.Major}

}
Catch
{
Write-host "Couldn't connect to the server check if is joined the domain or FW issues"
Break
}


#Task 2: Hardening 2016-2019 / 2012 //Install PS version 5.1 for 2012


if ($OSVersion -eq "6")
{

cmd.exe /c "D:\Repository\Working\Antonio\Server_provisioning\Source\PsExec64.exe -accepteula \\$hostname -s cmd.exe /c "c:\temp\source\WMF5.1_OnlyFor2012R2\install.cmd" 2> nul"
#Invoke-Command -ComputerName $hostname -ScriptBlock {cd "C:\Temp\Source\WMF5.1_OnlyFor2012R2\"; start-process .\install.cmd}

Write-Host "Hardening Process"
$Result_HD = Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "C:\Temp\Source\Soft_Hardening_2016\DisableServices_2012.cmd"}
Write-Host "This is OS version $OSVersion"

}else
{

Write-Host "Hardening Process"
$Result_HD = Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "C:\temp\Source\Soft_Hardening_2016\DisableServices.cmd"}
Write-Host "This is OS version $OSVersion"
}


Task 3: Install .Net 4.8
Write-Host "Installing .Net 4.8"
$Result_Net = Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "C:\temp\Source\.Net_4.8\ndp48-x86-x64-allos-enu.exe /q /norestart"}

#Task 4: Install MissMarple
Write-Host "Installing Miss Marple"
$Result_Miss_M = Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "C:\temp\Source\MMA_1.14\silent.bat"}


#Task 5: Install NB
Write-Host "Installing NetBackup"
$Result_NB = Invoke-command -ComputerName $Hostname -ScriptBlock {
Function Install_Netbackup {
$server = hostname
Remove-Item -Path "HKLM:\SOFTWARE\Veritas" -Recurse -Force -ErrorAction SilentlyContinue
cmd.exe /c "c:\temp\Source\NetBackup_8.1.2_Win\x64\silentclient.cmd"

}
Install_Netbackup

Function NB_Cert_GDC
{
$server = hostname
$Swisscom_Master="sssmnbu60.global.schindler.com"
$NB_Token="EKGCCDJSGIZLQJUV"
cd "c:\Program Files\VERITAS\NetBackup\bin";
cmd.exe /c "nbcertcmd -getCertificate -host $server -server $Swisscom_Master -token $NB_Token"
}

NB_Cert_GDC

}


#Update registry for a Vcenter Server

Invoke-command -ComputerName $Hostname -ScriptBlock {reg import "c:\source\custom.reg"} -ErrorAction SilentlyContinue




Restart-Computer -ComputerName $hostname -Force -Verbose -ErrorAction SilentlyContinue



start-sleep (300)
Wait-on



####################### 3rd step ###########################################

Write-Host "Step 3.- Some additonal software" -ForegroundColor white -BackgroundColor DarkGreen

#Task 1: Function

Invoke-Command -ComputerName $hostname -ScriptBlock {$OSWMI=Get-WmiObject -class Win32_OperatingSystem;$OSWMI.Description=$args[0];$OSWMI.put() } -ArgumentList($Description )

#Task 2: Install SEP
Write-Host "Installing SEP AV"
Invoke-Command -ComputerName $Hostname -ScriptBlock { & cmd.exe /c "msiexec.exe /i c:\temp\Source\SEP_14.3.558.0000\sep64.msi" /quiet /norestart}


#Task 3: Zabbix
Write-Host "Installing Zabbix version 4.2.1"
$Result_Zabbix = Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "c:\temp\source\Zabbix_4.2.1_OSD\Install.cmd"} -ErrorAction SilentlyContinue



#Task 4: BGINFO
Write-Host "Installing BGinfo v4.27"
Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "C:\temp\source\BGINFO_V4.27\install.cmd"}


#Task 5: Defrag disable task
#Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "schtasks /change /tn "microsoft\windows\defrag\ScheduledDefrag" /disable"}


start-sleep (10)

Restart-Computer -ComputerName $hostname -Force -Verbose -ErrorAction SilentlyContinue

start-sleep (120)
Wait-on


####################### 4th step ###########################################

Write-Host "Step 4.- This could be long, please wait on Patching!" -ForegroundColor white -BackgroundColor DarkGreen

#Task 1: Patching
Write-Host ""
Write-Host "Server Patching Please Wait, Server will reboot and patch several times"
Write-Host ""
try
{
cmd.exe /c "D:\Repository\Working\Antonio\Server_provisioning\Source\PsExec64.exe -accepteula \\$hostname -s cmd.exe /c "c:\temp\source\wuinstall /search /download /install" 2> nul" >> "D:\Repository\Working\Antonio\Server_provisioning\Logs\Patching\Patch_$hostname.txt"
}
catch
{
Write-Host ""
}

Restart-Computer -ComputerName $hostname -Force -Verbose -ErrorAction SilentlyContinue

start-sleep (360)
Wait-on

#Task 2: Patching again

Write-Host ""
Write-Host "Server Patching Please Wait, Server will reboot and patch several times"
try
{
cmd.exe /c "D:\Repository\Working\Antonio\Server_provisioning\Source\PsExec64.exe -accepteula \\$hostname -s cmd.exe /c "c:\temp\source\wuinstall /search /download /install" 2> nul" >> "D:\Repository\Working\Antonio\Server_provisioning\Logs\Patching\Patch_$hostname.txt"
}
catch
{
Write-Host ""
}

Restart-Computer -ComputerName $hostname -Force -Verbose -ErrorAction SilentlyContinue


start-sleep (120)
Wait-on


#Task 3: Landesk Final Agent
Write-Host "Installing Landesk Final Agent"
Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "c:\temp\Source\SSA2016.3V2_with_status.exe"}

#Task 4: Local PW
Write-Host "Admin Changed"
Invoke-Command -ComputerName $hostname -ScriptBlock {cmd.exe /c "c:\temp\Source\ChangeL_A_P_04_2016\SetLocalUserPW_v2_2012_1.exe"}

start-sleep (10)

#Task 4: Cleaning Files on remote server
Write-Host "Cleaning"
Invoke-Command -ComputerName $hostname -ScriptBlock {Remove-Item -Path "C:\temp\source" -Recurse -Force}

#Setting trusted host variable to null
Write-Host "Removing trusted host"
set-item WSMan:\localhost\Client\TrustedHosts -Value "" -Force


################### ending email ###############################


      
            Write-Host "------------------------------";
            Write-Host "Server $hostname Completed";

            $PSEmailServer = "smtp.eu.schindler.com"
            $date = Get-Date -format d;

            $Subject = "Server completed: $Hostname"
            
            $From = "scc-support-zar.es@schindler.com"
            $To = "scc-support-zar.es@schindler.com"

            $Body = @"
This mail is being generated automatically by Schindler Powershell Script SPS (ventoa1)

Please check all the software has been Installed, in case you find any problems, please contact the Server Team.

SCC Server Competence Center - Schindler Support

"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body"