<#        
.DESCRIPTION 
    This script allows the user to copy a file or folder to a remote computer and execute a Powershell 
     script afterwards.  After the script has executed, it then cleans up after itself.  It includes  
     validation such as checking to ensure the computer is online and if PS remoting is enabled on the  
     remote computer.    
.EXAMPLE 
     
.EXAMPLE 
     
.PARAMETER FolderPath 
     Any folders (on the local computer) that need copied to the remote computer prior to execution 
.PARAMETER ScriptPath 
     The Powershell script path (on the local computer) that needs executed on the remote computer 
.PARAMETER RemoteDrive 
     The remote drive letter the script will be executed on and the folder will be copied to 
.PARAMETER Computername 
    The remote computer to execute files on. 
#> 
[CmdletBinding()] 
param ( 
    [Parameter(Mandatory = $True, 
               ValueFromPipeline = $True, 
               ValueFromPipelineByPropertyName = $True)] 
    [string]$Computername, 
    [Parameter(Mandatory = $True, 
               ValueFromPipeline = $False, 
               ValueFromPipelineByPropertyName = $False)] 
    [string]$FolderPath, 
    [Parameter(Mandatory = $True, 
               ValueFromPipeline = $False, 
               ValueFromPipelineByPropertyName = $False)] 
    [string]$ScriptPath, 
    [Parameter(Mandatory = $True, 
               ValueFromPipeline = $False, 
               ValueFromPipelineByPropertyName = $False)] 
    [string]$CheckType,
    [Parameter(Mandatory = $True, 
               ValueFromPipeline = $False, 
               ValueFromPipelineByPropertyName = $False)] 
    [string]$Products,
    [Parameter(Mandatory = $True, 
               ValueFromPipeline = $False, 
               ValueFromPipelineByPropertyName = $False)] 
    [string]$Resultspath,
    [Parameter(Mandatory = $False, 
               ValueFromPipeline = $False, 
               ValueFromPipelineByPropertyName = $False)] 
    [string]$RemoteDrive = 'C' 
) 
 
begin { 
    ## http://www.leeholmes.com/blog/2009/11/20/testing-for-powershell-remoting-test-psremoting/ 
    function Test-PsRemoting { 
        param ( 
            [Parameter(Mandatory = $true)] 
            $computername 
        ) 
         
        try { 
            $errorActionPreference = "Stop" 
            $result = Invoke-Command -ComputerName $computername { 1 } 
        } catch { 
            Write-Verbose $_ 
            return $false 
        } 
         
        ## I’ve never seen this happen, but if you want to be 
        ## thorough…. 
        if ($result -ne 1) { 
            Write-Verbose "Remoting to $computerName returned an unexpected result." 
            return $false 
        } 
        $true 
    } 

    $ScriptName = $ScriptPath | Split-Path -Leaf 
    $RemoteFolderPath = $FolderPath | Split-Path -Leaf 
    $RemoteScriptPath = "$RemoteDrive`:\$RemoteFolderPath\$ScriptName"
    $RemotePath = "\\$Computername\$RemoteDrive`$\$RemoteFolderPath" 

    Write-Verbose "Validating prereqs for remote script execution..." 
    if (!(Test-Path $FolderPath)) { 
        throw 'Folder path does not exist' 
    } elseif (!(Test-Path $ScriptPath)) { 
        throw 'Script path does not exist' 
    } elseif ((Get-ItemProperty -Path $ScriptPath).Extension -ne '.ps1') { 
        throw 'Script specified is not a Powershell script' 
    } elseif (!(Test-Connection -Computername  $Computername -Quiet -Count 1)) { 
        throw 'Computer is not reachable' 
    } elseif (!(Test-PsRemoting $Computername)) { 
        throw 'Remoting is not enabled on remote computer'     
    }
    elseif (Test-Path $RemotePath) { 
        throw "RemotePath $RemotePath already exists"
        Write-Host "RemotePath $RemotePath already exists"
        sleep 30
        Exit
        
    } 
     
} 


process { 
    Write-Verbose "Copying the folder $FolderPath to the remote computer $ComputerName..." 
    Copy-Item $FolderPath -Recurse "\\$Computername\$RemoteDrive`$" -Force 
    Write-Verbose "Copying the script $ScriptName to the remote computer $ComputerName..." 
    Copy-Item $ScriptPath "\\$Computername\$RemoteDrive`$\$RemoteFolderPath" -Force 
    Write-Verbose "Executing $RemoteDrive`:\$RemoteFolderPath\$ScriptName on the remote computer $ComputerName..." 
    Invoke-Command -ComputerName $Computername -ScriptBlock { & $using:RemoteScriptPath -CheckType $args[0] -Products $args[1] } -ArgumentList $CheckType,$Products #-Credential $ComputerName\Administrator -Authenticatio Basic
    New-Item -Path $ResultsPath\$Computername -ItemType Directory
    Copy-Item "\\$Computername\$RemoteDrive`$\$RemoteFolderPath\Logs\*.*" $ResultsPath\$Computername -Force 
} 
 
end { 
    Write-Verbose "Cleaning up the copied folder and script from remote computer $Computername..." 
        Remove-Item "\\$ComputerName\$RemoteDrive`$\$RemoteFolderPath" -Recurse -Force 
}