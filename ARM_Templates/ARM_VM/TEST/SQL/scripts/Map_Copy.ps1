# Map storage account per subscription

# Devops Subscription Variable
$subs = $args[0]


#Functions

# EU-PROD
function euprod 
{
    $connectTestResult = Test-NetConnection -ComputerName 10.38.14.7 -Port 445
    if ($connectTestResult.TcpTestSucceeded)
    {
        # Save the password so the drive will persist on reboot
        cmd.exe /C "cmdkey /add:`"10.38.14.7`" /user:`"Azure\stprodgeneric0001`" /pass:`"U7JZ4rXAfdk10d5RwkDbpC4xnhrFRW3Fnx3DJdLCN3puRBadRIyXyHZ/7e5inv3NUKOfwhiRzwELVkh5USI2Fg==`""
        # Mount the drive
        New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.38.14.7\servers" -Persist
    }    
    else
    {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    }
}

# EU-NONProd
function eunonprod 
{
    $connectTestResult = Test-NetConnection -ComputerName 10.37.14.28 -Port 445
    if ($connectTestResult.TcpTestSucceeded) 
    {
        # Save the password so the drive will persist on reboot
        cmd.exe /C "cmdkey /add:`"10.37.14.28`" /user:`"Azure\stnonprodgeneric0001`" /pass:`"553DvxEiHCz07QEFvgmiUHxoHdXF1htL5Lu/KqWlHkBib9exZ8ClmXVwaz+nOFBhuNy0Uskes/miVH0lIw9bqA==`""
        # Mount the drive
        New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.37.14.28\servers" -Persist
    }
    else
    {
        Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    }
}

# AP-PROD
function approd 
{
    $connectTestResult = Test-NetConnection -ComputerName 10.87.14.6 -Port 445
    if ($connectTestResult.TcpTestSucceeded)
    {
        # Save the password so the drive will persist on reboot
        cmd.exe /C "cmdkey /add:`"10.87.14.6`" /user:`"Azure\stgenericap0003`" /pass:`"6d3ebecvALianZFs/1NY6nTkhcxY8Ef4G+C4pqvjeuphtvWxOG7I6Gq18clZZuT7omgZUvUVoxg4QnADb6pD6A==`""
        # Mount the drive
        New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.87.14.6\servers" -Persist
    }
    else
    {
        Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    }
}

# AM-PROD
function amprod 
{
    $connectTestResult = Test-NetConnection -ComputerName 10.165.14.9 -Port 445
    if ($connectTestResult.TcpTestSucceeded)
    {
        # Save the password so the drive will persist on reboot
        cmd.exe /C "cmdkey /add:`"10.165.14.9`" /user:`"Azure\stprodgeneric0002`" /pass:`"jRmy/4OLwP0KPste5SNkXhTjki4xV2AQACtK7LY3qdF02Q4q6nqhBQqq0BhVAt+cygzDxG/S3/rh8XEenoV5zg==`""
        # Mount the drive
        New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.165.14.9\servers" -Persist
    }
    else
    {
        Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    }
}

# AM-NONProd
function amnonprod 
{
    $connectTestResult = Test-NetConnection -ComputerName 10.166.14.8 -Port 445
    if ($connectTestResult.TcpTestSucceeded)
    {
        # Save the password so the drive will persist on reboot
        cmd.exe /C "cmdkey /add:`"10.166.14.8`" /user:`"Azure\stnonprodgeneric0002`" /pass:`"GJSSDqSkGpHFMlyQFAWMoi5hRnUu7Tzzl+MfvFDiAtpgKkPzm8T7YdwnFmePwafSrJKzOhzCEZUvmj4YYyM2hw==`""
        # Mount the drive
        New-PSDrive -Name X -PSProvider FileSystem -Root "\\10.166.14.8\servers" -Persist
    }
    else
    {
        Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    }
}


# Main

switch ($subs)
{
    "s-sis-eu-prod-01" {euprod}
    "s-sis-eu-nonprod-01" {eunonprod}
    "s-sis-ap-prod-01" {approd}
    "s-sis-am-prod-01" {amprod}
    "s-sis-am-nonprod-01" {amnonprod}
}
copy-item -path "x:\provision\" -destination "c:\" -recurse -force


