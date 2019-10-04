$date = Get-Date -Format "dd.MM.yyyy, HH:mm"

#region basic report with propertys
Get-EventLog -LogName System -after 14.05.2019 -Newest 20 | ConvertTo-Html  | Out-File "eventrep1.html"
.\eventrep1.html
#endregion

#region basic report with propertys
Get-EventLog -LogName System -after 14.05.2019 -Newest 20 |
ConvertTo-Html -Property EventID, MachineName, Index, Category, EntryType,
Message, Source, InstanceId, TimeGenerated | Out-File "eventrep2.html"
.\eventrep2.html
#endregion

#region with title

Get-EventLog -LogName System -after 14.05.2019 -Newest 20 | 
Select-Object EventID, @{Name="Host";Expression={($_.MachineName.split('.'))[0]}}, Index, Category,EntryType, Message, Source, InstanceId, TimeGenerated | 
ConvertTo-Html -Title "Report from Systemlog" -PreContent "<h1>Report created by $env:USERNAME at $date</h1>" | Out-File "eventrep3.html"
.\eventrep3.html
#endregion


#region with style
$head = "<style>
td {width:100px; max-width:300px; background-color:lightgrey;}
table {width:100%;}
th {font-size:14pt;background-color:yellow;}
</style>

<title>Report from Systemlog</title>"

Get-EventLog -LogName System -after 14.05.2019 -Newest 20 | Select-Object EventID, @{Name="Host";Expression={($_.MachineName.split('.'))[0]}},Index, Category,
 @{Name="Typ";Expression={$_.EntryType}},Message, Source, InstanceId, TimeGenerated | ConvertTo-Html -Head $head `
-PreContent "<h1>Report created by $env:USERNAME at $date</h1>" | Out-File ".\eventrep4.html"

#endregion
