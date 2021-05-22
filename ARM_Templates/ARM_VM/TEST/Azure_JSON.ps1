Clear-Host


$Title = "*-*-*-*-*-*-*-*-*-*-*-*-*-* Please Select an Option -*-*-*-*-*-*-*-*-*-*-*-*-*"

Clear-Host
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'AZURE VM CREATION'
$form.Size = New-Object System.Drawing.Size(400,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(220,450)
$OKButton.Size = New-Object System.Drawing.Size(75,40)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(45,450)
$CancelButton.Size = New-Object System.Drawing.Size(75,40)
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
$label1.Text = 'Include the location, Ex: westeurope'
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
$label2.Text = 'Include the osDiskType from: Ex:Premium_LRS'
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
$label3.Text = 'Include Size of the VM, EX Standard_B2s'
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






############################################################################################################# WinVer



$label4 = New-Object System.Windows.Forms.Label
$label4.Location = New-Object System.Drawing.Point(10,290)
$label4.Size = New-Object System.Drawing.Size(360,20)
$label4.Text = 'Include the Windows Version 2016/2019'
$form.Controls.Add($label4)


$textBox4 = New-Object System.Windows.Forms.TextBox
$textBox4.Location = New-Object System.Drawing.Point(10,320)
$textBox4.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textBox4)
    $Font = New-Object System.Drawing.Font("Times New Roman",13,[System.Drawing.FontStyle]::regular)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Form.Font = $Font
$form.Topmost = $true

$form.Add_Shown({$textBox4.Select()})
#$result = $form.ShowDialog()





############################################################################################################# Resource Group




$label5 = New-Object System.Windows.Forms.Label
$label5.Location = New-Object System.Drawing.Point(10,360)
$label5.Size = New-Object System.Drawing.Size(360,20)
$label5.Text = 'Include the Resource Group'
$form.Controls.Add($label5)


$textBox5 = New-Object System.Windows.Forms.TextBox
$textBox5.Location = New-Object System.Drawing.Point(10,390)
$textBox5.Size = New-Object System.Drawing.Size(360,20)
$form.Controls.Add($textBox5)
    $Font = New-Object System.Drawing.Font("Times New Roman",13,[System.Drawing.FontStyle]::regular)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Form.Font = $Font
$form.Topmost = $true

$form.Add_Shown({$textBox5.Select()})






#$listBox = New-Object System.Windows.Forms.Listbox
#$listBox.Location = New-Object System.Drawing.Point(10,40)
#$listBox.Size = New-Object System.Drawing.Size(260,20)
#
#$listBox.SelectionMode = 'MultiExtended'
#
#[void] $listBox.Items.Add('Item 1')
#[void] $listBox.Items.Add('Item 2')
#[void] $listBox.Items.Add('Item 3')
#[void] $listBox.Items.Add('Item 4')
#[void] $listBox.Items.Add('Item 5')
#
#$listBox.Height = 70
#$form.Controls.Add($listBox)
#$form.Topmost = $true








############################################################################################################################# Show Form
$result = $form.ShowDialog()





#Start AZ Script
##############################################################################################################################


if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $Hostname = $textBox.Text
    $Location = $textBox1.Text
    $osDiskType = $textBox2.Text
    $size = $textBox3.Text
    $Win_ver = $textBox4.Text
    $virtualMachineRG = $textBox5.Text

}
else
{
break
}

    $Hostname = $textBox.Text
    $Location = $textBox1.Text
    $osDiskType = $textBox2.Text
    $size= $textBox3.Text
    $Win_ver = $textBox4.Text
    $virtualMachineRG = $textBox5.Text


    Write-host "$Hostname - $Location - $osDiskType - $size - $Win_ver - $virtualMachineRG"




#######################################################################################################################

$Parameters_Base = "D:\Repository\Working\Antonio\Azure\Template_From_Image\parameters_v1.json"
$Template_2019 = "D:\Repository\Working\Antonio\Azure\Template_From_Image\Templates\template_2019.json"
$Template_2016 = "D:\Repository\Working\Antonio\Azure\Template_From_Image\Templates\template_2016.json"



###########################
#Common Variables
#$virtualMachineRG = "SDG-TEST"


#########################

$Parameters = ([System.IO.File]::ReadAllText($Parameters_Base)  | ConvertFrom-Json)



######################################################################################
#Changing Azure Parameters for new VM

#$hostname = Read-Host "Include the Hostname, Ex: zzzwsr0010"
#$location = Read-host "Please Include the location, Ex: westeurope"
#$osDiskType = Read-host "Include the osDiskType from: Ex:Premium_LRS https://docs.microsoft.com/en-us/rest/api/storagerp/srp_sku_types"
#$size = Read-host "Please include the size of the VM, Ex: Standard_B2s https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs"
#$Win_Ver = Read-host "Please include the OS version EX: 2016 or 2019"


$Parameters.parameters.virtualMachineName.value = "$hostname"
$Parameters.parameters.networkInterfaceName.value = "$hostname`_01"
$Parameters.parameters.location.value = "$location"
$Parameters.parameters.osDiskType.value =  "$osDiskType"
$Parameters.parameters.virtualMachineSize.value = "$size"

$Parameters_Final = "D:\Repository\Working\Antonio\Azure\Template_From_Image\NewServers\parameters_$hostname.json"

$Parameters | ConvertTo-Json | Out-File -FilePath $Parameters_Final -Encoding utf8 -Force




#######################################################################################################
#Running New VM Command

if ($Win_Ver -eq "2019")
{

Connect-AzureRmAccount
write-host "VM will be created in AZURE, please wait at least 20 minutes"
New-AzureRmResourceGroupDeployment -ResourceGroupName $virtualMachineRG -TemplateFile "$Template_2019" -TemplateParameterFile "$Parameters_Final"

} else

      { if ($Win_Ver -eq "2016")
        {

        Connect-AzureRmAccount

            #workflow Start-VM {
            #parallel {
            #        
            #InlineScript { 
            #function Start-Sleep($seconds) {
            #$doneDT = (Get-Date).AddSeconds($seconds)
            #while($doneDT -gt (Get-Date)) {
            #$secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
            #$percent = ($seconds - $secondsLeft) / $seconds * 100
            #Write-Progress -Activity "Deploying in Azure" -Status "Please Wait" -SecondsRemaining $secondsLeft -PercentComplete $percent
            #[System.Threading.Thread]::Sleep(500)
            #}
            #Write-Progress -Activity "Deploying in Azure" -Status "Please Wait" -SecondsRemaining 0 -Completed
            #}
            #Start-sleep(600)
            #}
            write-host "VM will be created in AZURE, please wait at least 20 minutes"
            New-AzureRmResourceGroupDeployment -ResourceGroupName $virtualMachineRG -TemplateFile "$Template_2016" -TemplateParameterFile "$Parameters_Final"
       #              }
       #     }
       # Start-VM
                    
                   
        }
        else
        {Write-host "Please include a correct Windows OS Version" -ForegroundColor Red -BackgroundColor White
        }
} 

Write-Host "Please wait 20 minutes more and check Server Tweap to start the provisioning"
Start-Sleep -Seconds 50