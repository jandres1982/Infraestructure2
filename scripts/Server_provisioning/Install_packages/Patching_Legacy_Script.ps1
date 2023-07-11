Set-StrictMode –Version latest
function Test-IsElevatedUser {
    param ()
    $IsElevatedUser = $false
    try {
        $WindowsIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $WindowsPrincipal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $WindowsIdentity
        $IsElevatedUser =  $WindowsPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Elevated privileges is undetermined; the error was: '{0}'." -f $_
    }
    return $IsElevatedUser
}

function Install-WindowsUpdates {
    [cmdletbinding(SupportsShouldProcess=$True,ConfirmImpact="Medium")]
    Param (
        [parameter(mandatory=$false)][switch]$RebootIfRequired,
        [parameter(mandatory=$false)][switch]$IncludeHidden,
        [parameter(mandatory=$false)][switch]$ListOnly
    )
    Begin {
        $ScriptName = $MyInvocation.MyCommand.Name
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
        if (Test-IsElevatedUser) {
            New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
            $Message = "Script: " + $ScriptName + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "10104" -EntryType "Information" -Message $Message
        }
        $UpdateSession = New-Object -ComObject 'Microsoft.Update.Session'
        $UpdateSession.ClientApplicationID = 'Install Windows Updates via PowerShell'
        $ReBootRequired = $false
    }
    Process {
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchQuery = "IsInstalled=0 and Type='Software'"
         if ($IncludeHidden.IsPresent) {
            $SearchQuery += ' and IsHidden=0'
        }
        try {
            $SearchResult = $UpdateSearcher.Search($SearchQuery)
        } catch [System.Management.Automation.MethodInvocationException]  { # [Exception from HRESULT: 0x8024402C] {
        <#
        #>
            Write-Error $_.Exception.ToString()
            Write-Host "You can try the following to correct a HRESULT: 0x8024402C error and then retry this function"
            Write-Host "   netsh winhttp reset proxy"
            Write-Host "   net stop wuauserv"
            Write-Host "   net start wuauserv"
            Write-Host "   Microsoft KB900936 : http://support.microsoft.com/kb/900936"
            $Error = $_.Exception.ToString()
            $Error = $Error.substring(0,380)
            $Message = "Script: " + $ScriptName + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString() + "`nWSUS HRESULT: " + $Error
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "10106" -EntryType "Information" -Message $Message

            return
        } catch {
            Write-Error $_.Exception.ToString()
            return
        }
        if ($ListOnly.IsPresent) {
            ForEach ($Update in $SearchResult.Updates) {
                New-Object -TypeName PSObject -Property @{
                    Title = $Update.Title; Description = $Update.Description; SupportUrl = $Update.SupportUrl; 
                        UninstallationNotes = $Update.UninstallationNotes; RebootRequired = $Update.RebootRequired}
            }
        } elseif ($SearchResult.Updates.Count -ne 0) {
            if (Test-IsElevatedUser) {
                # Write Event Log Info with Updates Count
                $Message = "Script: " + $ScriptName + "`nScript User: " + $Username + "`nTime: " + (Get-Date).toString() + "`nNumber of Updates: " + $SearchResult.Updates.Count
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "10105" -EntryType "Information" -Message $Message

                Write-Verbose 'Creating a collection of updates to download:'
                $UpdatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
                ForEach ($Update in $SearchResult.Updates) {
                    $addThisUpdate = $false
                    if ($Update.InstallationBehavior.CanRequestUserInput) {
                        Write-Verbose "> Skipping: $($Update.Title) because it requires user input"
                    } elseif ($Update.EulaAccepted -eq $false) {
                        if ($pscmdlet.ShouldProcess($Update.Title + " has a license agreement that must be accepted:")) {
                            $Update.AcceptEula()
                            $addThisUpdate = $true
                        } else {
                            Write-Verbose "> Skipping: $($Update.Title) because the license agreement was declined"
                        }
                    } else {
                        $addThisUpdate = $true
                    }
                    if ($addThisUpdate) {
                        Write-Verbose "Adding: $($Update.Title) to download list"
                        #-> Insert Check if Update is downloaded
                        if ($Update.IsDownloaded) {Write-Verbose "$($Update.Title) is downloaded already"}   
                        else {$UpdatesToDownload.Add($Update) |Out-Null}
                    }
                }
                if ($UpdatesToDownload.Count -ne 0) {
                    $DLCount = $UpdatesToDownload.Count
                    if ($pscmdlet.ShouldProcess("Download $DLCount Windows Update Package(s)")) {
                        Write-Verbose 'Downloading updates...'
                        $Downloader = $UpdateSession.CreateUpdateDownloader()
                        $Downloader.Updates = $UpdatesToDownload
                        $Downloader.Download() | Out-Null
                    }
                }
                $UpdatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
                $rebootMayBeRequired = $false
                $Installer = $UpdateSession.CreateUpdateInstaller()
                foreach ($Update in $SearchResult.Updates) {
                    $UpdateTitle = $Update.Title
                    if ($Update.IsDownloaded) {
                        Write-Verbose "Successfully downloaded ready to install : ($UpdateTitle)"
                        $UpdatesToInstall.Add($Update) |Out-Null        
                        if ($Update.InstallationBehavior.RebootBehavior -gt 0) {
                            $rebootMayBeRequired = $true
                        }
                        $Installer.Updates = $UpdatesToInstall
                        if ($pscmdlet.ShouldProcess("Install $UpdateTitle")) {
                            Write-Verbose "Installing $UpdateTitle"
                            $InstallationResult = $Installer.Install()
                            if ($InstallationResult.RebootRequired) { 
                                $ReBootRequired = $true
                            }
                            Write-Verbose "Installation Result: $($InstallationResult.ResultCode)"
                            Write-Verbose "Reboot Required: $($InstallationResult.RebootRequired)"
                            Write-Verbose 'Listing of updates installed and individual installation results'            
                            for($i=0; $i -lt $UpdatesToInstall.Count; $i++) {
                                New-Object -TypeName PSObject -Property @{
                                    Title = $UpdateTitle; Result = $InstallationResult.ResultCode}
                            }
                        }
                        $UpdatesToInstall.Clear()
                    }
                }
            } else {
                $Message = "Script: " + $ScriptName + "`nScript User: " + $Username + "`nError: Elevated user required for installation"
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "10106" -EntryType "Information" -Message $Message
                throw "Elevated user required for installation"
            }
        } else {
#            Write-Verbose "No updates are available" 
            $Message = "Script: " + $ScriptName + "`nScript User: " + $Username + "`nNo updates are available"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "10103" -EntryType "Information" -Message $Message
        }
    }
    End {
        $Message = "Script: " + $ScriptName + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "10104" -EntryType "Information" -Message $Message
        if ($ReBootRequired -and $RebootIfRequired.IsPresent) {
            Restart-Computer -Force
        } 
    }
}



# Initialize Variables
$WUauclt = "c:\windows\system32\WUauclt.exe"

# Start WindowsUpdates patch installation if patch window is open
Install-WindowsUpdates -RebootIfRequired -Confirm

# Update WSUS Server
Write-Verbose 'Update WSUS Server'
cmd.exe /c "$WUauclt /detectnow"
cmd.exe /c "$WUauclt /reportnow"