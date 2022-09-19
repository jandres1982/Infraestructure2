Workflow Do-Inline2
{
    param($location)
    $Files = InlineScript
    {
    Get-ChildItem $using:location -file -Filter *.ps1 -Recurse

    Checkpoint-Workflow
    }

    $Files

}

#(Dir Function:Do-inline2).ScriptBlock |out-file C:\inline.ps1
#(Dir Function:Do-inline2).Xamldefinition | out-file C:\xaml_definition.xml

#Workflow Test-Workflow
#{
#    $a = Invoke-LongRunningFunction
#    InlineScript { \\Server\Share\Get-DataPacks.ps1 $Using:a}
#    Checkpoint-Workflow
#
#    Invoke-LongRunningFunction
#    {
#        ...
#    }
#}