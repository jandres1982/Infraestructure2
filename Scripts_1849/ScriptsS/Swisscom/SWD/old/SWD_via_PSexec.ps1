[CmdletBinding()]
Param(
   
   [Parameter(Mandatory=$True, Position=1)]
   [string]$package
)

# #################################### General ##############################
#region General definitions

$ScriptRootFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptNameFull = $MyInvocation.MyCommand.Definition

#$ScriptRootFolder = "D:\Scripts\Swisscom\SWD"
#$ScriptNameFull = "D:\Scripts\Swisscom\SWD\SWD_via_PSexec.ps1"

$ScriptName = [IO.Path]::GetFileNameWithoutExtension($ScriptNameFull)
$CurrentUser = $env:USERNAME
$DateTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DateLog = Get-Date -Format 'yyyyMMdd'
$Logfile = "$ScriptRootFolder\log\$($package)_$($DateTimestamp).txt"
$PSexec = "$ScriptRootFolder\bin\PsExec.exe"
#endregion General definitions
# ######################################################################

$computers = Get-Content $ScriptRootFolder\_Targets\$package.txt
$setupfiles = Get-ChildItem "$ScriptRootFolder\_Packages\$package\"
$command = "Install.cmd"

foreach ($computer in $computers) {
       
    If (!(Test-Path \\$computer\c$\temp\SWDPSEXEC\$package)) {
    mkdir \\$Computer\c$\temp\SWDPSEXEC\$package
    }
    Foreach ($file in $setupfiles) {
    Copy-Item $file.fullname "\\$computer\c$\temp\SWDPSEXEC\$package\" -Force -Confirm:$false
    }
   
   $PSexecParameter = "\\$computer -d -h -s \\$computer\c$\temp\SWDPSEXEC\$package\$command"
   $Execute = Start-Process -FilePath $PSexec -ArgumentList $PSexecParameter
   Write-host $Execute
   
}