   function Start-Sleep($seconds) {
            $doneDT = (Get-Date).AddSeconds($seconds)
            while($doneDT -gt (Get-Date)) {
            $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
            $percent = ($seconds - $secondsLeft) / $seconds * 100
            Write-Progress -Activity "Software Installation Progress" -Status "Installing" -SecondsRemaining $secondsLeft -PercentComplete $percent
            [System.Threading.Thread]::Sleep(500)
            }
            Write-Progress -Activity "Software Installation Progress" -Status "Installing" -SecondsRemaining 0 -Completed
            }
            



workflow Start-VM {
            parallel {
                     InlineScript { 
                     
            function Start-Sleep($seconds) {
            $doneDT = (Get-Date).AddSeconds($seconds)
            while($doneDT -gt (Get-Date)) {
            $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
            $percent = ($seconds - $secondsLeft) / $seconds * 100
            Write-Progress -Activity "Software Installation Progress" -Status "Installing" -SecondsRemaining $secondsLeft -PercentComplete $percent
            [System.Threading.Thread]::Sleep(500)
            }
            Write-Progress -Activity "Software Installation Progress" -Status "Installing" -SecondsRemaining 0 -Completed
            }
            
            Start-Sleep (500)         
                     
                     
                     
                      }   
                     echo "it works"
                     }
            }

Start-VM