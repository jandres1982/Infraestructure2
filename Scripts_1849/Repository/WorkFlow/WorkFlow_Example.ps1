####################### WORKFLOW IN SEQUENCE ############################

Workflow Do-Sequence
{

Sequence
{
Get-CimInstance Win32_Bios
Get-CimInstance Win32_ComputerSystem

}

}


####################### WORKFLOW IN PARALLEL ############################
Workflow Do-Parallel
{

Parallel
{
Get-CimInstance Win32_Bios -PSComputerName shhwsr1848
Get-CimInstance Win32_Bios -PSComputerName shhwsr1849

}

}

####################### WORKFLOW IN EACH PARALLEL ############################
Workflow Do-Parallel2
{
$objs = @('Win32_Bios', 'Win32_ComputerSystem')

Foreach -Parallel ($obj in $objs)
{
Get-CimInstance $obj
}

}



######################## Check time between SEQUENCE AND PARALLEL ############################
#
#$starts = get-date
#1..100 |foreach {$o=do-sequence}
#$ends = Get-date
#"Sequence: $(($ends-$starts).totalmilliseconds)"
#
#$startsp = get-date
#1..100 |foreach {$o=do-parallel}
#$endsp = Get-date
#"Parallel: $(($endsp-$startsp).totalmilliseconds)"
#
