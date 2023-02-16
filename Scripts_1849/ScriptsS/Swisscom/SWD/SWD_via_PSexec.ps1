#############################################################################
# Script: Copy a folder including files to a list of servers and execute 
#         install.cmd within that folder using psexec on the remote computer
#        
#
# Author: Michael Barmettler
# Date: 25.04.2017
#
# Requirements: - TCP445 & TCP139 to the remote computer
#               - Admin rights on the remote machine
#
# 
# Instruction: 1. Create a folder under the "_Packages" directory and place all
#                 required files including a install.cmd with the command to be
#                 executed on the particular machine. (e.g Folder name = WinZip)
#
#              2. Create a .txt file under the "_Targets" folder which is named
#                 the SAME as the folder you created above! (e.g. WinZip.txt)
#                 List all the servers that should be processed in the txt file:
#                 Important: Make sure that you only specify servers that you
#                 can access with the same credentials (e.g don't mix DMZ and Global servers, run the script on DMZ for DMZ machines)
#
#              3. Run the script and specify the "Name" (e.g. WinZip) for the package.
#                 The script will run agains all Servers specified in the "_Targets\WinZip.txt" and
#                 process the files in the "_Packages\WinZip" directory. A Log file is stored 
#                 in the log directory. 
#                
#############################################################################


[CmdletBinding()]
Param(
   
   [Parameter(Mandatory=$True, Position=1)]
   [string]$package
)

# #################################### General ##############################
#region General definitions

#$ScriptRootFolder = "D:\Scripts\Swisscom\SWD"
#$ScriptNameFull = "D:\Scripts\Swisscom\SWD\SWD_via_PSexec.ps1"

$ScriptRootFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptNameFull = $MyInvocation.MyCommand.Definition
$ScriptName = [IO.Path]::GetFileNameWithoutExtension($ScriptNameFull)
$CurrentUser = $env:USERNAME
$DateTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DateLog = Get-Date -Format 'yyyyMMdd'
$Logfile = "$ScriptRootFolder\log\$($package)_$($DateTimestamp).txt"
$PSexec = "$ScriptRootFolder\bin\PsExec.exe"
#endregion General definitions
# ######################################################################


function Invoke-Psexec {
    param(
        [Parameter(Mandatory=$true)] [string] $command_str,
        [Parameter(Mandatory=$true)] [string] $remote_computer,
        [Parameter(Mandatory=$true)] [string] $psexec_path,
        [switch] $include_blank_lines
    )

    begin {
        $remote_computer_regex_escaped = [regex]::Escape($remote_computer)

        # $ps_exec_header = "`r`nPsExec v2.2 - Execute processes remotely`r`nCopyright (C) 2001-2016 Mark Russinovich`r`nSysinternals - www.sysinternals.com`r`n"

        $ps_exec_regex_headers_array = @(
            '^\s*PsExec v\d+(?:\.\d+)? - Execute processes remotely\s*$',
            '^\s*Copyright \(C\) \d{4}(?:-\d{4})? Mark Russinovich\s*$',
            '^\s*Sysinternals - www\.sysinternals\.com\s*$'
        )

        $ps_exec_regex_info_array = @(
            ('^\s*Connecting to ' + $remote_computer_regex_escaped + '\.{3}\s*$'),
            ('^\s*Starting PSEXESVC service on ' + $remote_computer_regex_escaped + '\.{3}\s*$'),
            ('^\s*Connecting with PsExec service on ' + $remote_computer_regex_escaped + '\.{3}\s*$'),
            ('^\s*Starting .+ on ' + $remote_computer_regex_escaped + '\.{3}\s*$')
        )

        $bypass_regex_array = $ps_exec_regex_headers_array + $ps_exec_regex_info_array

        $exit_code_regex_str = ('^.+ exited on ' + $remote_computer_regex_escaped + ' with error code (\d+)\.\s*$')

        $ps_exec_args_str = ('"\\' + $remote_computer + '" ' + $command_str)
    }

    process {
        $return_dict = @{
            'std_out' = (New-Object 'system.collections.generic.list[string]');
            'std_err' = (New-Object 'system.collections.generic.list[string]');
            'exit_code' = $null;
            'bypassed_std' = (New-Object 'system.collections.generic.list[string]');
        }

        $process_info = New-Object System.Diagnostics.ProcessStartInfo
        $process_info.RedirectStandardError = $true
        $process_info.RedirectStandardOutput = $true
        $process_info.UseShellExecute = $false
        $process_info.FileName = $psexec_path
        $process_info.Arguments = $ps_exec_args_str

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $process_info
        $process.Start() | Out-Null

        $std_dict = [ordered] @{
            'std_out' = New-Object 'system.collections.generic.list[string]';
            'std_err' = New-Object 'system.collections.generic.list[string]';
        }

        # $stdout_str = $process.StandardOutput.ReadToEnd()
        while ($true) {
            $line = $process.StandardOutput.ReadLine()
            if ($line -eq $null) {
                break
            }
            $std_dict['std_out'].Add($line)
        }

        # $stderr_str = $process.StandardError.ReadToEnd()
        while ($true) {
            $line = $process.StandardError.ReadLine()
            if ($line -eq $null) {
                break
            }
            $std_dict['std_err'].Add($line)
        }

        $process.WaitForExit()

        ForEach ($std_type in $std_dict.Keys) {
            ForEach ($line in $std_dict[$std_type]) {
                if ((-not $include_blank_lines) -and ($line -match '^\s*$')) {
                    continue
                }

                $do_continue = $false
                ForEach ($regex_str in $bypass_regex_array) {
                    if ($line -match $regex_str) {
                        $return_dict['bypassed_std'].Add($line)
                        $do_continue = $true
                        break
                    }
                }
                if ($do_continue) {
                    continue
                }

                $exit_code_regex_match = [regex]::Match($line, $exit_code_regex_str)

                if ($exit_code_regex_match.Success) {
                    $return_dict['exit_code'] = [int] $exit_code_regex_match.Groups[1].Value
                } elseif ($std_type -eq 'std_out') {
                    $return_dict['std_out'].Add($line)
                } elseif ($std_type -eq 'std_err') {
                    $return_dict['std_err'].Add($line)
                } else {
                    throw 'this conditional should never be true; if so, something was coded incorrectly'
                }
            }
        }

        return $return_dict
    }
}


$computers = Get-Content $ScriptRootFolder\_Targets\$package.txt
$setupfiles = Get-ChildItem "$ScriptRootFolder\_Packages\$package\"
$command = "Install.cmd"

Write-Host "This script will copy  all files under:"
Write-Host "$ScriptRootFolder\_Packages\$package\"
Write-Host "and execute - $command - on all servers specified in:"
Write-host "$ScriptRootFolder\_Targets\$package.txt"
[void](Read-Host 'Press Enter to continue…')


foreach ($computer in $computers) {
       
    If (!(Test-Path \\$computer\c$\temp\SWDPSEXEC\$package)) {
    mkdir \\$Computer\c$\temp\SWDPSEXEC\$package
    }
    Foreach ($file in $setupfiles) {
    Copy-Item $file.fullname "\\$computer\c$\temp\SWDPSEXEC\$package\" -Force -Confirm:$false
    }
   
   $PSexecParameter = "-d -h -s \\$computer\c$\temp\SWDPSEXEC\$package\$command"
   $Execute = Invoke-Psexec -remote_computer $computer -command_str $PSexecParameter -psexec_path $PSexec
   $Execute.std_err >> $Logfile
}

