$date = $(get-date -format yyyy-MM-ddTHH-mm)

$reservationObject = [System.Collections.ArrayList]::new()

    $reservations=Get-Azreservation
    
    foreach ($reservation in $reservations)
    {
        $subid = $reservation.AppliedScopes
        $subid = $subid.split("/")[2]
        $sub= get-azsubscription -SubscriptionId "$subid"
        [void]$reservationObject.add([PSCustomObject]@{
        Subscription = $sub.Name
        Location = $reservation.Location
        ReservationName = $reservation.DisplayName
        Status = $reservation.DisplayProvisioningState
        Sku = $reservation.Sku
        Quantity = $reservation.Quantity
        ExpiryDate = $reservation.ExpiryDate
        })
    }
 
$report = 'Reservations_'+'_Report_'+"$date"+'.csv'
$reservationObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report


$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "nahum.sancho@schindler.com","alfonso.marques@schindler.com"

$Subject = "Reservations Report"
$Attachment = $report
$Body = @"
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Dear all,</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Please find attached the Report of Reservations.</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Best regards,</span></div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<p><span style="font-size: medium; font-family: arial, helvetica, sans-serif; color: #ff0000;">Schindler Server Team - DevOps Automated Report</span></p>
<p>&nbsp;</p>
</div>
<div>&nbsp;</div>
"@
#https://htmled.it/

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment -BodyAsHtml