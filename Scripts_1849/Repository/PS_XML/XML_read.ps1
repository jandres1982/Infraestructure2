[xml]$xmldata = get-content "D:\Repository\Working\Antonio\PS_XML\Example_XML.xml"

$hostname  = $xmldata.Order.Server | %{$_.Hostname} | select-object -unique
