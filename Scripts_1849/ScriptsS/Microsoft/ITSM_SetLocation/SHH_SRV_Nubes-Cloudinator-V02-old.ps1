#############################################################################
# Script: Sets Server Location in SACM for Servers in ITSM
# Author: Michael Barmettler
# Date: 14.06.2016
# Comments: Core ID "9" = Qual. Core ID "10" = Prod
#############################################################################


[CmdletBinding()]
Param(
   
   [Parameter(Mandatory=$True, Position=1)]
   [string]$coreid
)


#Specify Error Email Address
$mail = "michael.barmettler@ch.schindler.com"

#Specify LANDesk Location IDs
$bew = "02787d0c-d8cc-4508-ae3b-d5cbeafd16b3" #Bern Wankdorf
$zoi = "128be5e7-afce-4421-9e81-29ca29d9e5c5" #Bern Zollikofen

#Specify the SOAP uri of Tweap
$uri = "http://tweap.global.schindler.com/WebService/WebService.asmx"

#Get Yesterday date to compare it against the data source (migrated yesterday)
#$yesterday = (Get-Date).AddDays(-2).ToString('dd.MM.yyyy')

#Get last hour (migrated last hour)
$lasthour = (Get-Date).AddHours(-1).ToString('dd.MM.yyyy HH')


function Get-Type 
{ 
    param($type) 
 
$types = @( 
'System.Boolean', 
'System.Byte[]', 
'System.Byte', 
'System.Char', 
'System.Datetime', 
'System.Decimal', 
'System.Double', 
'System.Guid', 
'System.Int16', 
'System.Int32', 
'System.Int64', 
'System.Single', 
'System.UInt16', 
'System.UInt32', 
'System.UInt64') 
 
    if ( $types -contains $type ) { 
        Write-Output "$type" 
    } 
    else { 
        Write-Output 'System.String' 
         
    } 
} #Get-Type 
 
####################### 
<# 
.SYNOPSIS 
Creates a DataTable for an object 
.DESCRIPTION 
Creates a DataTable based on an objects properties. 
.INPUTS 
Object 
    Any object can be piped to Out-DataTable 
.OUTPUTS 
   System.Data.DataTable 
.EXAMPLE 
$dt = Get-psdrive| Out-DataTable 
This example creates a DataTable from the properties of Get-psdrive and assigns output to $dt variable 
.NOTES 
Adapted from script by Marc van Orsouw see link 
Version History 
v1.0  - Chad Miller - Initial Release 
v1.1  - Chad Miller - Fixed Issue with Properties 
v1.2  - Chad Miller - Added setting column datatype by property as suggested by emp0 
v1.3  - Chad Miller - Corrected issue with setting datatype on empty properties 
v1.4  - Chad Miller - Corrected issue with DBNull 
v1.5  - Chad Miller - Updated example 
v1.6  - Chad Miller - Added column datatype logic with default to string 
v1.7 - Chad Miller - Fixed issue with IsArray 
.LINK 
http://thepowershellguy.com/blogs/posh/archive/2007/01/21/powershell-gui-scripblock-monitor-script.aspx 
#> 
function Out-DataTable 
{ 
    [CmdletBinding()] 
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject) 
 
    Begin 
    { 
        $dt = new-object Data.datatable   
        $First = $true  
    } 
    Process 
    { 
        foreach ($object in $InputObject) 
        { 
            $DR = $DT.NewRow()   
            foreach($property in $object.PsObject.get_properties()) 
            {   
                if ($first) 
                {   
                    $Col =  new-object Data.DataColumn   
                    $Col.ColumnName = $property.Name.ToString()   
                    if ($property.value) 
                    { 
                        if ($property.value -isnot [System.DBNull]) { 
                            $Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)") 
                         } 
                    } 
                    $DT.Columns.Add($Col) 
                }   
                if ($property.Gettype().IsArray) { 
                    $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1 
                }   
               else { 
                    $DR.Item($property.Name) = $property.value 
                } 
            }   
            $DT.Rows.Add($DR)   
            $First = $false 
        } 
    }  
      
    End 
    { 
        Write-Output @(,($dt)) 
    } 
 
} #Out-DataTable

########################################################################
#Export Data from Cloudinator SQL Server

Import-Module SQLPS

$ServerInstance = "10.10.100.112"
$DB = "MigDB"
$SQLUser = "sa-db-schindlerexport"
$SQLpw = "3d81e118-6859-4d91-8948-f36710de0d91"


$SQLquery =@" 
 
SELECT [server].server_name
      ,[rhserver_ls]
      ,[rhserver_lswave]
      ,[rhserver_lsstart]
      ,[rhserver_lsend]
      ,[server].server_site
      ,[server].server_itbc
      ,[server].server_contact
      ,[server].server_contactemail
FROM [MigDB].[dbo].[rhserver],[MigDB].[dbo].[server] WHERE [MigDB].[dbo].[rhserver].rhserver_id = [MigDB].[dbo].[server].server_id AND [server].server_site IS NOT NULL
 
"@ 

$migdata = invoke-sqlcmd -query $SQLquery -serverinstance $ServerInstance -database $DB -Username $SQLUser -Password $SQLpw | Out-DataTable

#########################################################################
#Import Migration Data and select only VMs where finishdate is equal to yesterday and migrated successfully (status = 1)


#Replace Locations with LANDesk Location ID

$migdata | foreach-object {
$_.server_site = $_.server_site.replace("bew",$bew)
$_.server_site = $_.server_site.replace("zoi",$zoi)
}

$systems = $migdata | Where-Object {($_.rhserver_lsend -like "$lasthour*") -and ($_.rhserver_ls -eq "1")}

#Create WebProxy connection to Tweap over SOAP
$proxy = $null                        
try{            
    $proxy = New-WebServiceProxy -Uri $uri -UseDefaultCredential -ErrorAction Stop
}            
catch{             
    Send-MailMessage -To $mail -Subject "NUBES Auto-ITSM-Location - Error" -body "ERROR: Failed to connect to Tweap" -From "$env:computername@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com"
    Exit
}


#Set Location via SOAP for every system
foreach ($system in $systems)
 {
 $setlocation = $proxy.SetLocation($coreid,$system.server_name,$system.server_site)
 #$setlocation
 if ($setlocation.ToString() -match "OK:")
 {
 #OK, Location set:
 Write-Host "$($system.server_name) - $setlocation - $($system.server_site)" 
  } 
 else
 {
 #Failure, Location NOT set:
 $ErrorSetLoc = "$($system.server_name) - $setlocation"
 $Errors +=$ErrorSetLoc
 }
 }
if ($Errors) {Send-MailMessage -To $mail -Subject "NUBES Auto-ITSM-Location - Error" -body $Errors -From "$env:computername@ch.schindler.com" -SmtpServer "smtp.eu.schindler.com"}