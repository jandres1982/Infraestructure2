$Title = "*-*-*-*-*-*-*-*-*-*-*-*-*-* Please Select an Option -*-*-*-*-*-*-*-*-*-*-*-*-*"

Clear-Host
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Final Provisioning Script'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'Manual'
$form.Location = New-Object System.Drawing.Point(250,250)

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(180,100)
$OKButton.Size = New-Object System.Drawing.Size(75,40)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(45,100)
$CancelButton.Size = New-Object System.Drawing.Size(75,40)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please include the server Hostname'
$form.Controls.Add($label)


$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,60)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)
    $Font = New-Object System.Drawing.Font("Times New Roman",13,[System.Drawing.FontStyle]::regular)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Form.Font = $Font
$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $server = $textBox.Text
    
}
else
{
break
}

Function showmenu {
    Clear-Host
         
Write-Host "You are in Server/Hostname: $server"
Write-Host ""
Write-Host "$Title"                 
Write-Host "*                                                                            *"
Write-Host "*           1. Remove from WSUS and Zabbix                                   *" -BackgroundColor Black
Write-Host "*           2. Remove from DHCP (on-going)                                   *" -BackgroundColor DarkGray
Write-Host "*           3. Change server                                                 *" -BackgroundColor Black
Write-Host "*           4. Exit                                                          *" -BackgroundColor DarkGray
Write-Host "*                                                                            *"
Write-Host "*                                                                            *"
Write-Host "*-*-*-*-*-*-*-*-*-*- Final Server Tasks Script -*-*-*-*-*-*-*-*-*-*-*"

Write-host ""

Write-Warning "Please use this script at your own risk, logs are not yet available"
Write-host ""
Write-Host "Please for any change contact (ventoa1)" -ForegroundColor Green

}

showmenu
Write-host ""


while(($inp = Read-Host -Prompt "Select an option") -ne "4"){

switch($inp){

        1 {

            #GDC Decommission Script
            $SHH_WSUS = "shhwsr1238"
            $SHH_WSUS_KG = "shhwsr2538"
            #$servers = gc "D:\Repository\Working\Antonio\Decommission_GDC\Servers.txt"
            #$servers = "CRDWSR0048"
            $servers = $server
            $user = "svcshhwsusmaint"
            $pw = 
            
            $secureString = ConvertTo-SecureString -AsPlainText -Force -String $pw
            $credential = New-Object `
            	-TypeName System.Management.Automation.PSCredential `
            	-ArgumentList "$user",$secureString
            
            $s = New-ZbxApiSession "https://zabbix.global.schindler.com/zabbix/api_jsonrpc.php" $credential
            
            Foreach ($Server in $Servers)
            {
            
            Function Remove_WSUS
            {
            Import-Module -Name PoshWSUS
            #
            #Write-host "Checking the Patching group for Server $Server in the WSUS"
            
            Connect-PSWSUSServer -WsusServer $SHH_WSUS -port 8530 >> $null
            $Result_1 = Get-PSWSUSClient -Computername $Server | Select FullDomainName,ComputerGroup,RequestedTargetGroupName,OSDescription,LastSyncTime,IPAddress
            Connect-PSWSUSServer -WsusServer $SHH_WSUS_KG -port 8530 >> $null
            $Result_2 = Get-PSWSUSClient -Computername $Server | Select FullDomainName,ComputerGroup,RequestedTargetGroupName,OSDescription,LastSyncTime,IPAddress
            
            If ($Result_1 -eq $null -and $Result_2 -eq $null)
                {write-host "$server, cannot be found on $SHH_WSUS or $SHH_WSUS_KG" -ForegroundColor Gray
                }else
                    {
                     Write-Output "Checking Connection to $SHH_WSUS"
                     Connect-PSWSUSServer -WsusServer $SHH_WSUS -port 8530 >> $null
                     Remove-PSWSUSClient -Computername $Server -WarningAction SilentlyContinue
                     Write-Output "Checking Connection to $SHH_WSUS_KG"
                     Connect-PSWSUSServer -WsusServer $SHH_WSUS_KG -port 8530 >> $null
                     Remove-PSWSUSClient -Computername $Server -WarningAction SilentlyContinue
                     }
            
            }
            
            Function Remove_Zabbix
            {
            Import-Module PSZabbix
            $Remove_Zabbix = Get-ZbxHost $server | Remove-ZbxHost
            if ($Remove_Zabbix)
                {Write-Output "$Server Zabbix Host Removed"}
                else
                    {Write-host "Zabbix host for $server cannot be found" -ForegroundColor Gray
                    }
            
            }
            
            Write-Host "---------"
            Write-Host "Working on Server $Server" -ForegroundColor Yellow
            Write-Output "----- WSUS -----" -InformationAction Continue
            Remove_WSUS
            Write-Output "---- Zabbix -----" -InformationAction Continue
            Remove_Zabbix
            
            #"OU=RES,OU=Groups,OU=Admin_Global,OU=NBI12,DC=global,DC=schindler,DC=com" 
            #(Get-ADGroup -filter * -searchbase "OU=Groups,OU=NBI12,DC=global,DC=schindler,DC=com" | Where-Object {$_.SamAccountName -like "*RES_SY_"+$server+"_ADMIN"}).SamAccountName
            }


                pause;
                break
        }

        3 {
                Clear-Host
                Write-Host "-------- Change of server ------------";
    
                $Server = Read-host "Include another Server, current one is $Server"
                

                pause;
                break
            }

        4 {"exit"; break}
        default {Write-Host -ForegroundColor red -BackgroundColor white "Invalid option. Please select another option";pause}

       
    }

showmenu
}