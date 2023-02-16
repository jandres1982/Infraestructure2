
#Provision Script for Zaragoza Server Team
#Please use it carefully at your own risk
#Don't change the code unless is necessary and is approved. 



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
Write-Host "*           1. Format Non SQL Disk                                           *" -BackgroundColor Black
Write-Host "*           2. Format SQL Disks                                              *" -BackgroundColor DarkGray
Write-Host "*           3. Add SQL Group *                                               *" -BackgroundColor Black
Write-Host "*           4. Add Local Admin Group *                                       *" -BackgroundColor DarkGray
Write-Host "*           5. Renew NB Certificates (Only Swisscom VCenter) and lower case  *" -BackgroundColor Black
Write-Host "*           6. Add IIS Group *                                               *" -BackgroundColor DarkGray
Write-Host "*           7. Add ADM User *                                                *" -BackgroundColor Black
Write-Host "*           8. Install Netbackup Client (Only Swisscom VCenter NUBES_I)      *" -BackgroundColor DarkGray
Write-Host "*           9. Install .Net 3.5                                              *" -BackgroundColor Black
Write-Host "*           10. Check Server Last Update                                     *" -BackgroundColor DarkGray
Write-Host "*           11. Refresh Kerberos Token                                       *" -BackgroundColor Black
Write-Host "*           12. Change Server                                                *" -BackgroundColor DarkGray
Write-Host "*           13. Check the SCSI ID from volume Letter                         *" -BackgroundColor Black
Write-Host "*           14. Extend drive size to the Maximum Size                        *" -BackgroundColor DarkGray
Write-Host "*           15. Check Systeminfo (KB installed, Uptime and more)             *" -BackgroundColor Black
Write-Host "*           16. Remove Computer Object (Warning this cannot be undone)       *" -BackgroundColor DarkGray
Write-Host "*           17. Remove Computer Object from WSUS Server (only Global Domain) *" -BackgroundColor Black
Write-Host "*           18. Check WSUS Group (only Global Domain)                        *" -BackgroundColor DarkGray
Write-Host "*           19. Create Computer Object in Global (use server tweap)          *" -BackgroundColor Black
Write-Host "*           20. Force Windows Update Script (check Server List)              *" -BackgroundColor DarkGray
Write-Host "*           21. Schedule a Snapshot From CSV by David Sancho (r)             *" -BackgroundColor Black
Write-Host "*           22. Install VmWare tools version 11.2.6.17901274                 *" -BackgroundColor DarkGray
Write-Host "*           23. Netbackup Media Servers for Nubes IV                         *" -BackgroundColor Black
Write-Host "*           24. Exit                                                         *" -BackgroundColor DarkGray
Write-Host "*                                                                            *"
Write-Host "*                                                                            *"
Write-Host "*-*-*-*-*-*-*-*-*-*- Final Server Tasks Script by Tonino-*-*-*-*-*-*-*-*-*-*-*"

Write-host ""

Write-Warning "Please use this script at your own risk, logs are not yet available"
Write-host ""
Write-Host "Please for any change contact (ventoa1)" -ForegroundColor Green

}

showmenu
Write-host ""


while(($inp = Read-Host -Prompt "Select an option") -ne "24"){

switch($inp){

        1 {
            Clear-Host
            Write-Host "Working on it, please wait...";
            Write-Host "-------------- Non SQL Disk -----------------------";

            invoke-command -ComputerName $server -ScriptBlock {
            ###########################################################################################
            Function No_SQL_Disk
            {
            Get-Disk |
            
            Where partitionstyle -eq ‘raw’ |
            
            Initialize-Disk -PartitionStyle GPT -PassThru
            
            New-Partition -AssignDriveLetter "1" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel “Data” -Confirm:$false
            
            
            }
            ########################################################################################
            No_SQL_Disk

            }
            

            pause;
            break
        }
        2 {

            Clear-Host
            Write-Host "Working on it, please wait...";
            Write-Host "--------------- Add SQL Disks ----------------";
            

            invoke-command -ComputerName $server -ScriptBlock {
            ###########################################################################################
            Function SQL_Disk
            {
            Get-Disk |
            
            Where partitionstyle -eq ‘raw’ |
            
            Initialize-Disk -PartitionStyle GPT -PassThru
            
            New-Partition -AssignDriveLetter "1" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel “DATA_SYSDB” -Confirm:$false
            
            New-Partition -AssignDriveLetter "2" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel “DATA_USERDB” -Confirm:$false
            
            New-Partition -AssignDriveLetter "3" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel “DATA_TRANS_LOG” -Confirm:$false
            
            New-Partition -AssignDriveLetter "4" -UseMaximumSize |
            Format-Volume -FileSystem NTFS -NewFileSystemLabel “DATA_TEMPDB” -Confirm:$false
            }

            ###########################################################################################
              SQL_Disk

             }


            
            pause;
            break
        }


            
        3 {

                   Clear-Host

            Write-Host "------------------------------";
            Write-Host "--------------  Add SQL Group -----------------";

            invoke-command -ComputerName $server -ScriptBlock {
            ###########################################################################
            Function Add_SQL_Group {

            Try
            {

            $SQL_Group = "SHH_RES_SY_SERVER_SQL-ADMIN"
            $GroupAdm = [ADSI]”WinNT://localhost/Administrators”
            $GroupAdm.Add(“WinNT://global/$SQL_Group")

            }

            catch

            {

            Write-host "Check if the SQL Admin group is already included"

            }

            }

            ##########################################################################
            Add_SQL_Group

            }
            pause;
            break
            }




            4 {

            Clear-Host
            Write-Host "------------ Add Local Admin Group ---------------------";


            invoke-command -ComputerName $server -ScriptBlock {

            ###########################################################################
            Function Local_admin_group
            
            {
            
            try
            {
            $Host_Name = hostname
            $Server = $Host_Name.ToUpper()
            $Head = $server.Substring(0,3)
            $Header_ADGroup = "$head"+"_RES_SY_"
            $Tail_ADGroup = "_ADMIN"
            $Server_AD_Group = echo "$Header_ADGroup$Server$Tail_ADGroup"
            $GroupObj = [ADSI]”WinNT://localhost/Administrators”
            $GroupObj.Add(“WinNT://global/$Server_AD_Group")
            }
            catch
            {

            Write-Host "Check if Local Admin Group is already included"
            }
            }


            ###########################################################################
            Local_admin_group

            }
            pause;
            break
            }


            5 {

            Clear-Host
            Write-Host "-------- This option renews the Netbackup Certificates and set lowercase to the client name ------------";

            invoke-command -ComputerName $server -ScriptBlock {
            ####################################################################
            Function NB_Cert_GDC
            {
            $server = hostname
            $Swisscom_Master="sssmnbu60.global.schindler.com"
            $NB_Token="IXHVBVDEPTLFHEFN"
            cd "c:\Program Files\VERITAS\NetBackup\bin";
            cmd.exe /c "nbcertcmd -getCertificate -host $server -server $Swisscom_Master -token $NB_Token"
            }
            Function Set_lower_case
            {
            $server = hostname
            $server_low = $server.ToLower()
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Veritas\NetBackup\CurrentVersion\Config" Browser -Value $server_low
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Veritas\NetBackup\CurrentVersion\Config" Client_Name -Value $server_low
            }

            #####################################################################
            NB_Cert_GDC
            Set_lower_case

            }
            
            pause;
            break
            }



        6 {
            Clear-Host
            Write-Host "-------- Add the IIS Group ------------";
            invoke-command -ComputerName $server -ScriptBlock {

            #################### ADD IIS Group #############################
            Function Add_IIS_Group {
            
            Try
            {

            $SQL_Group = "SHH_RES_SY_SERVER_IIS-ADMIN"
            $GroupAdm = [ADSI]”WinNT://localhost/Administrators”
            $GroupAdm.Add(“WinNT://global/$SQL_Group")
            
            }


            catch

            {

            Write-host "Check if the IIS Admin group is already included"

            }




            }
            ################################################################

            Add_IIS_Group


            }


              pause;
            break
            }


            7 {
            Clear-Host
            Write-Host "-------- Add an ADM user ------------";
            invoke-command -ComputerName $server -ScriptBlock {

            ######################### add a specific user to admin group of the server
            Function Add_ADM_User {
            
            Try
            {
            $ADM_User = Read-host "Please include the ADM user to add to administrator Group"
            $GroupAdm = [ADSI]”WinNT://localhost/Administrators”
            $GroupAdm.Add(“WinNT://global/$ADM_User")
            }
            Catch
            {
                "Please check if the user is already in the administrator group or it doesn't exist"
            }
            }
            #######################################################################################

            Add_ADM_User

            }


              pause;
            break
            }

                    8 {
            Clear-Host
            Write-Host "-------- Install Netbackup ------------";

            Copy-item -Path "D:\Repository\Working\Antonio\Final_Provisioning_Script\Source\NetBackup_8.1.2_Win" -Destination "\\$server\c$\temp" -Recurse -ErrorAction SilentlyContinue #### NETBACKUP Files Copy

            invoke-command -ComputerName $server -ScriptBlock {

            ####################################################################################
            Function Install_Netbackup {

            Write-host "----------- You have choosen to Install Netbackup --------------"
            $server = hostname
            Remove-Item -Path "HKLM:\SOFTWARE\Veritas" -Recurse -Force -ErrorAction SilentlyContinue
            cd c:\temp\
            #please change in the cmd file the setup to be: C:\TEMP\NetBackup_8.1.2_Win\x64\SETUP.EXE /CLIENT -s /REALLYLOCAL /RESPFILE:'%RESPFILENAME%'
            cmd.exe /c "C:\temp\NetBackup_8.1.2_Win\x64\silentclient.cmd"
            
            }

            Function Remove_Netbackup_Files {
            Write-host "--------------- Remove Netbackup Files ------------"
            Remove-Item "C:\temp\NetBackup_8.1.2_Win" -Recurse
            }

            function Start-Sleep($seconds) {
            $doneDT = (Get-Date).AddSeconds($seconds)
            while($doneDT -gt (Get-Date)) {
            $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
            $percent = ($seconds - $secondsLeft) / $seconds * 100
            Write-Progress -Activity "Software Installation Progress" -Status "Installing" -SecondsRemaining $secondsLeft -PercentComplete $percent
            [System.Threading.Thread]::Sleep(500)
            }
            Write-Progress -Activity "Software Installation Progress" -Status "Installing" -SecondsRemaining 0 -Completed
            }


            ####################################################################################

            Install_Netbackup
            Start-sleep (50)
            Remove_Netbackup_Files

            }


              pause;
            break
            }



                    9 {
            Clear-Host
            Write-Host "-------- Install .Net 3.5 ------------";

           
            Copy-item -Path "D:\Repository\Working\Antonio\Final_Provisioning_Script\Source\Net35" -Destination "\\$server\c$\temp" -Recurse -ErrorAction SilentlyContinue #### .NET Copy Sources


            invoke-command -ComputerName $server -ScriptBlock {
            ##############################################################################################################
            Function Install_Net35 {
            Write-host "--------------  You have choose to .NET 3.5 -----------"
            cd "c:\temp\net35"
            cmd.exe /c "C:\temp\Net35\install.cmd"
            }
            
            Function Rmfiles_Net35 {
            Remove-Item "C:\temp\Net35\" -Recurse
            Write-host ".Net 3.5 Files removed"
            }

            function Start-Sleep($seconds) {
            $doneDT = (Get-Date).AddSeconds($seconds)
            while($doneDT -gt (Get-Date)) {
            $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
            $percent = ($seconds - $secondsLeft) / $seconds * 100
            Write-Progress -Activity "Software Installation Progress" -Status "Installing" -SecondsRemaining $secondsLeft -PercentComplete $percent
            [System.Threading.Thread]::Sleep(500)
            }
            Write-Progress -Activity "Software Installation Progress" -Status "Installing" -SecondsRemaining 0 -Completed
            }

            #########################################################################################################
            Install_Net35
            Start-sleep (350)
            Rmfiles_Net35  


            }

              pause;
            break
            }



                                10 {
            Clear-Host
            Write-Host "-------- Check Last Time Server Was Updated ------------";

            
            invoke-command -ComputerName $server -ScriptBlock {

            ####################################################################################
            Function Check_Server_Last_Update {
            
            gwmi win32_quickfixengineering |sort installedon -desc | Select -First 1

            }



            ####################################################################################

            Check_Server_Last_Update

            }


              pause;
            break
            }




            11 {
            Clear-Host
            Write-Host "-------- Refresh Kerberos Token ------------";

            If ((Test-path -path "\\$server\c$\temp"))
            {
            invoke-command -ComputerName $server -ScriptBlock {

            ####################################################################################
            Function Refresh_Kerberos_Token {
            
            Write-Host "Working on Server $Server"
            
             cmd.exe /c "klist -li 0x3e7 purge"
             cmd.exe /c "gpupdate /force"

            }
             Refresh_Kerberos_Token
            }
           }
            else {
              Write-host "Server $server is not reachable from PowerShell"
            }
            
            

           
           
            
            pause;
            break
            }
            ####################################################################################

            12 {
            Clear-Host
            Write-Host "-------- Change of server ------------";

            $Server = Read-host "Include another Server, current one is $Server"
            



              pause;
            break
            }



            13 {
            Clear-host

            Invoke-Command -ComputerName $Server -ScriptBlock{
            
            $Server
            Write-host ""
            $Letter = Read-Host "Please include the drive letter"

            $Drive_Letter = $Letter + ":"
            
            $Disk = Get-WmiObject -Class Win32_logicaldisk -Filter "DeviceID = '$Drive_Letter'"
            
            $DiskPartition = $Disk.GetRelated('Win32_DiskPartition')
            
            $DiskDrive = $DiskPartition.getrelated('Win32_DiskDrive')
            
            $SCSI_Info = $DiskDrive | Select-Object -Property * | Select-Object SCSITargetId
            
            $SCSI_Number = $SCSI_Info.SCSITargetId
            
            Write-host "For the letter $Drive_Letter, the SCSI ID IS: $SCSI_Number"
            
            }

            
              pause;
            break
            }


        14 {
          Clear-Host
          
          Write-Host "You are in server $Server"
          Write-Host ""
          Write-host "You have choosen to resize the disk to the max possible size"
          Invoke-Command -ComputerName $Server -ScriptBlock{
          $Letter = Read-host "Can you include the drive letter?"
          "rescan" | diskpart
          $MaxSize = (Get-PartitionSupportedSize -DriveLetter $Letter).sizeMax 
          Resize-Partition -DriveLetter $Letter -Size $MaxSize


          }

               pause;
             break

        }



        15 {
          Clear-Host
          
          Write-Host ""
          Write-Host "Check Systeminfo for Server $Server"
          Write-host ""
          Invoke-Command -ComputerName $Server -ScriptBlock{
          Write-host "Checking server information please hold on"
          Write-host ""
          systeminfo


          }

               pause;
             break

        }


        16 {
          Clear-Host
          
          Write-Host ""
          Write-Host "Removing computer object $Server"
          Write-host ""
          try {
          Remove-ADComputer -Identity $server -Confirm:$false
          Write-host "Done"
          Write-host ""

          }
          catch {
          
          Write-host ""
          Write-host "Couldn't remove the Computer Object, sorry check permissions or existence"
          Write-host ""
          }
        

               pause;
             break

        }





        17 {

           #Import-Module PSWindowsUpdate
           Import-Module -Name PoshWSUS
           #Get-command -module PoshWSUS
           Write-host "Current Server: $Server"
           Write-host "Remove Computer from WSUS server"
           
        #   try
        #   {
        #    $Old_WSUS = "shhwsr0239"
        #    Write-host "Checking the old WSUS server for the Server $Server"
        #    Connect-PSWSUSServer -WsusServer $Old_WSUS -port 8530
        #    Remove-PSWSUSClient -Computername $server
        #    Disconnect-PSWSUSServer  
        #  }
        #  catch
        #  {
        #    Write-Warning "Connection to SHHWSR0239 Old WSUS server was not possible or the object doesn't exist"
        #  }

          try
          {
            $New_WSUS = "shhwsr1238"
            Write-host "Checking the Schinlder WSUS server for the Server $Server"
            Connect-PSWSUSServer -WsusServer $New_WSUS -port 8530
            Remove-PSWSUSClient -Computername $server
            Disconnect-PSWSUSServer  
          }
          catch
          {
            Write-Warning "Connection to SHHWSR1238 Schindler WSUS server was not possible or the object doesn't exist"
          }
           

          pause;
          break

     }




     18 {

      #Import-Module PSWindowsUpdate
      Import-Module -Name PoshWSUS
      #Get-command -module PoshWSUS
      Write-host "Current Server: $Server"
      Write-host "Check WSUS Server for a specific Client"
      
   # try
    # {
    #  $Old_WSUS = "shhwsr0239"
    #  Write-host "Checking the old WSUS server for the Server $Server"
    #  Connect-PSWSUSServer -WsusServer $Old_WSUS -port 8530
    #  Get-PSWSUSClient -Computername $server
    #  Disconnect-PSWSUSServer  
    #  Write-host "$Server is in the OLD WSUS Server"
    #}
    #catch
    #{
    #  Write-Warning "Connection to $Old_WSUS Old WSUS server was not possible or the object doesn't exist"
    #}


    try
     {
       $New_WSUS = "shhwsr1238"
       Write-host "Checking the Schinlder WSUS server for the Server $Server"
       Connect-PSWSUSServer -WsusServer $New_WSUS -port 8530
       Get-PSWSUSClient -Computername $server
       Disconnect-PSWSUSServer  
       Write-host "$Server is in the $new_WSUS WSUS Server"
     }
     catch
     {
       Write-Warning "Connection to $new_WSUS Schindler WSUS server was not possible or the object doesn't exist"
     }
      
     pause;
     break

}



     19 {


      Write-host "Current Server: $Server"
      Write-host "Create Computer Object"
      $Server_UP = $Server.ToUpper()
      $Function = ""
      $Function = Read-host "Please include the Function of the Server"
      $Description = "SHH Windows Server $Function"
      New-ADComputer -Name $Server_UP -Path "OU=EU,OU=Servers,OU=NBI12,DCglobal,DC=schindler,DC=com" -PasswordNotRequired $false -Description $Description
      
      
      ###############################
     # $Admin_Head = "SHH_RES_SY_"
     # $Admin_Tail="_ADMIN"
     # $Admin_Group = "$Admin_Head$Server_UP$Admin_Tail"
     # New-ADGroup -Name $Admin_Group -GroupCategory Security -GroupScope Universal -DisplayName "$Server_UP Administrators" -Path "OU=RES,OU=Groups,OU=Admin_Global,OU=NBI12,DC=dmz2,DC=schindler,DC=com" -Description "$Server_UP Administrators"

   
      
     pause;
     break

}



        20 {


        powershell.exe "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\WindowsUpdate_v2.ps1"





            pause;
            break
}

         

         21 {


        powershell.exe "D:\Repository\Working\Antonio\Scheduled_Snaps\snaps_programados_from_csv.ps1"





            pause;
            break
}


         22 {
        
        If ((Test-path -path "\\$server\c$\temp"))
            {
        Write-host "VmWare Tools will be copied to destination server $server, please wait..." -ForegroundColor Yellow
        Copy-Item -Path "D:\Repository\Working\Antonio\Final_Provisioning_Script\Source\VmTools" -Destination "\\$server\c$\temp\" -Force -Recurse
        Write-host "VmWare Tools file should be copied to c:\temp, please check" -ForegroundColor Blue
        invoke-command -ComputerName $server -ScriptBlock {powershell.exe c:\temp\vmtools\setup64.exe /s /v “/qn reboot=r”}
        write-host "VmWare tools should be installed please check" -ForegroundColor Green
       # Remove-Item -Path "\\$server\c$\temp\Vmtools.zip"
       # Remove-Item -Path "\\$server\c$\temp\VmTools\" -Recurse -Force
            }else
                {Write-host "$Server can't be reached"}

            pause;
            break
}




         23 {
        
        If ((Test-path -path "\\$server\c$\temp"))
            {
        Write-host "We will add the media servers for Netbackup on Nubes IV" -ForegroundColor Yellow
        Copy-Item -Path "D:\Repository\Working\Antonio\Final_Provisioning_Script\Source\nubes4.reg" -Destination "\\$server\c$\temp\" -Force -Recurse
        Write-host "Working on it..." -ForegroundColor DarkYellow
        sleep 1
        invoke-command -ComputerName $server -ScriptBlock {regedit /s C:\TEMP\nubes4.reg}
        get-service -ComputerName $server -Name 'NetBackup Client Service' | Restart-Service
        write-host "Media servers should be added" -ForegroundColor Green
        
       # Remove-Item -Path "\\$server\c$\temp\Vmtools.zip"
       # Remove-Item -Path "\\$server\c$\temp\VmTools\" -Recurse -Force
            }else
                {Write-host "$Server can't be reached"}

            pause;
            break
}



        24 {"exit"; break}
        default {Write-Host -ForegroundColor red -BackgroundColor white "Invalid option. Please select another option";pause}

       
    }

showmenu
}

Write-host ""
Write-host ""
Write-host "Thanks for using PS script for server provisioning" -BackgroundColor DarkGreen

Write-host ""
Write-host ""


#
#