function Get-LocalGroupMembers  
{  
    param(  
        [parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]  
        [Alias("Name")]  
        [string]$ComputerName,  
        [string]$GroupName = "Administrators"  
    )  
      
    begin {}  
      
    process  
    {  
        # If the account name of the computer object was passed in, it will  
        # end with a $. Get rid of it so it doesn't screw up the WMI query.  
        $ComputerName = $ComputerName.Replace("`$", '')  
  
        # Initialize an array to hold the results of our query.  
        $arr = @()  
  
        # Get hostname of remote system.  $computername could reference cluster/alias name.  Need real hostname for subsequent WMI query. 
        $hostname = (Get-WmiObject -ComputerName $ComputerName -Class Win32_ComputerSystem).Name 
 
        $wmi = Get-WmiObject -ComputerName $ComputerName -Query "SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$Hostname',Name='$GroupName'`""  
  
        # Parse out the username from each result and append it to the array.  
        if ($wmi -ne $null)  
        {  
            foreach ($item in $wmi)  
            {  
                $data = $item.PartComponent -split "\," 
                $domain = ($data[0] -split "=")[1] 
                $name = ($data[1] -split "=")[1] 
                $arr += ("$domain\$name").Replace("""","") 
                [Array]::Sort($arr) 
            }  
        }  
  
        $hash = @{ComputerName=$ComputerName;Members=$arr}  
        return $hash  
    }  
      
    end{}  
}


$servers = Get-Content .\ServersTESTSu8am.txt

$grouptocheck = "001_RES_SY_SERVER_ADMIN"



foreach ($server in $servers) {

    $LocalAdminMembers = (Get-LocalGroupMembers -ComputerName $server -GroupName Administrators).members
    if ($LocalAdminMembers -match $grouptocheck) {
    $objectismember = $true
    }
    else {
    $objectismember = $false
    }
    write-host "$server has group $grouptocheck = $objectismember"
    
}


