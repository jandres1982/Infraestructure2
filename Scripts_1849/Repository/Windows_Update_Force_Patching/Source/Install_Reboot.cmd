cd c:\admin\tools\Sysinternals
PSEXEC64.exe \\tstshhwsr1248 -s cmd /c c:\temp\wuinstall /install
PSEXEC64.exe \\tstshhwsr1248 -s cmd /c c:\temp\wuinstall /reboot
timeout 20