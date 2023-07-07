#Unregister-ScheduledTask -TaskName "Join Domain" -TaskPath "\" -Confirm:$false
Unregister-ScheduledTask -TaskName "Local Admin Group" -TaskPath "\" -Confirm:$false
Remove-Item -Path 'C:\provision' -Recurse -Force