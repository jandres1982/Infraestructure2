
Clear-Host
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Final Provisioning Script'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(180,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(45,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
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
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBox)

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





Function Generate-Form {

    Add-Type -AssemblyName System.Windows.Forms    
    Add-Type -AssemblyName System.Drawing

        # Build Form
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Final Server Provisioning Script"
    $Form.Size = New-Object System.Drawing.Size(800,600)
    $Form.StartPosition = "CenterScreen"
    $Form.Topmost = $True

    # Add Button
    $Button = New-Object System.Windows.Forms.Button
    $Button.Location = New-Object System.Drawing.Size(35,35)
    $Button.Size = New-Object System.Drawing.Size(300,50)
    $Button.Text = "Show Dialog Box"

    # Add Another Button
    $Button2 = New-Object System.Windows.Forms.Button
    $Button2.Location = New-Object System.Drawing.Size(35,95)
    $Button2.Size = New-Object System.Drawing.Size(180,100)
    $Button2.Text = "2 second button"

    $Font = New-Object System.Drawing.Font("Times New Roman",18,[System.Drawing.FontStyle]::Italic)
    # Font styles are: Regular, Bold, Italic, Underline, Strikeout
    $Form.Font = $Font
    
    ########################################## Form Resize and scroll
    $Form.AutoScroll = $True
    $Form.AutoSize = $False
    $Form.AutoSizeMode = "GrowAndShrink" #this can be change for  # or GrowOnly

    $Form.MinimizeBox = $False

    $Form.MaximizeBox = $False

    $Form.WindowState = "Normal"
    $Form.StartPosition = "CenterScreen"
       # CenterScreen, Manual, WindowsDefaultLocation, WindowsDefaultBounds, CenterParent
    $Form.Opacity = 0.9
    #$Form.BackColor = "Lime"
    $Image = [system.drawing.image]::FromFile("D:\Repository\Working\Antonio\SQL_New_Server_Rework\Source\2019-09-17_12-26-54.png")
    $Form.BackgroundImage = $Image

    $Form.BackgroundImageLayout = "None"

    # None, Tile, Center, Stretch, Zoom
    #$Form.Width = $Image.Width
    #$Form.Height = $Image.Height




    ########################################################################
    $Form.Controls.Add($Button)
    $Form.Controls.Add($Button2)

    #Add Button event 
    $Button.Add_Click(
        {    
		[System.Windows.Forms.MessageBox]::Show("Hello World." , "My Dialog Box")

        
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








        }
        }



    )
     
    #Show the Form 
    $form.ShowDialog()| Out-Null 
 
} #End Function 

 #Call the Function 
Generate-Form

