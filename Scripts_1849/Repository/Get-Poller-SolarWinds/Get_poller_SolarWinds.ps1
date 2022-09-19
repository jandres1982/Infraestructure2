$Correct_poller = "SHHWSR1899"

$XMLfile = "C:\Program Files (x86)\SolarWinds\Agent\SolarWinds.Agent.Service.exe.cfg"
[XML]$XML = Get-Content $XMLfile
$Current_poller = $XML.configuration.target.host0

if ($Current_poller -like $Correct_poller)
{cmd /c "exit 0"
}
else
{cmd /c "exit 1"
}

