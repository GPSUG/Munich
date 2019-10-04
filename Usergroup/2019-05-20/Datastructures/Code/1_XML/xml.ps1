

[xml]$XML = Get-Content -Path .\1_XML\config1.xml



$XML2 = New-Object System.XML.XMLDocument
$XML2.Load(".\1_XML\config1.xml")


#region
Write-host "----------Name"
$XML.User.RufC.Name

$XML2.GetElementsByTagName("Name")
$XML2.GetElementsByTagName("Name").OuterXML
Write-host "----------"

Write-host "----------Skills"
$XML.User.RufC.Skills.Info
Write-host "----------"


Write-host "----------Age"
$XML2.User.RufC.Age
Write-host "----------"


Write-host "----------Test"
$XML2.User.RufC.Name.ID
Write-host "----------"
#endregion